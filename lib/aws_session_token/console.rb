# frozen_string_literal: true

#
# AWS Session Token Gem - Tool to wrap AWS API to create and store
# Session tokens so that other commands/tools (e.g. Terraform) can function as
# necessary.
#
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

  # Helper class for outputting creds to console in export variable format.
  class Console

    def write(credentials)
      $stdout.puts "export AWS_ACCESS_KEY_ID=#{credentials.access_key_id}"
      $stdout.puts "export AWS_SECRET_ACCESS_KEY=#{credentials.secret_access_key}"
      $stdout.puts "export AWS_SESSION_TOKEN=#{credentials.session_token}"
    end
  end
end
