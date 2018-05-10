# frozen_string_literal: true

#
# AWS Session Token Gem - Tool to wrap AWS API to create and store Session tokens
# so that other commands/tools (e.g. Terraform) can function as necessary.
#
# Copyright 2018 Bryan Stopp <bryan.stopp@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module AwsSessionToken

  # Execute the process for getting & updating the session token.
  class CLI

    def run
      @options = Options.new
      @options.parse(ARGV)
      update_creds
      mfa = mfa_device
      token = token_prompt
      @user = session_token(mfa, token)
    end

    def update_creds
      credentials = Aws::SharedCredentials.new(path: @options.credentials_file, profile_name: @options.profile)
      Aws.config.update(credentials: credentials)
    rescue Aws::Errors::NoSuchProfileError
      warn "\nSpecified AWS Profile doesn't exist: #{@options.profile}"
      exit
    end

    def mfa_device
      iam_client = Aws::IAM::Client.new
      list = iam_client.list_mfa_devices(max_items: 1)
      return list[0].serial_number unless list.nil || list.empty?
      warn "\nSpecified profile/user doesn't have MFA device."
      warn "\nScript execution unnecessary."
      exit
    end

    def token_prompt
      cli = HighLine.new
      cli.ask "Specify the OTP Token for the profile #{@options.profile}:"
    end

    def session_token(mfa_device, otp)
      @sts_client = Aws::STS::Client.new
      @sts_client.get_session_token(duration_secionds: @options.duration,
                                    serial_number: mfa_device,
                                    token_code: otp)
    end

    def write_creds
      # Write the creds to the file
    end
  end
end
