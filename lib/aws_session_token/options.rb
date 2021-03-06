# frozen_string_literal: true

#
# AWS Session Token Gem - Tool to wrap AWS API to create and store Session tokens
# so that other commands/tools (e.g. Terraform) can function as necessary.
#
# Copyright 2018 Bryan Stopp <bryan.stopp@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AwsSessionToken

  # Options class to define properties for the command line.
  class Options

    SESSION_PROFILE = 'session_profile'
    DURATION = 3600

    attr_accessor :console, :credentials_file, :duration, :profile, :profile_provided, :session_profile, :token, :user

    def initialize
      creds = Aws::SharedCredentials.new
      self.credentials_file = creds.path
      self.profile = creds.profile_name
      self.duration = DURATION
      self.profile_provided = false
      self.console = false
    end

    def parse(args)
      define_options.parse!(args)
      validate
    end

    private

    def define_options
      opts = OptionParser.new
      opts.banner = 'Usage: aws_session_token [options]'
      opts.separator('')

      # Additional options
      file_option(opts)
      user_option(opts)
      profile_option(opts)
      session_profile_option(opts)
      console_option(opts)
      duration_option(opts)
      token_option(opts)
      common_options(opts)
      opts
    end

    def file_option(opts)
      opts.on('-f', '--file FILE', 'Specify a custom credentials file.') do |f|
        self.credentials_file = f
      end
    end

    def user_option(opts)
      opts.on('-u', '--user USER',
              'Specify the AWS User name for passing to API.') do |u|
        self.user = u
      end
    end

    def profile_option(opts)
      opts.on('-p', '--profile PROFILE',
              'Specify the AWS credentials profile to use. Also sets user, if user is not provided.') do |p|
        self.profile = p
        self.profile_provided = true
      end
    end

    def session_profile_option(opts)
      opts.on('-s', '--session [SESSION_PROFILE]',
              'Specify the name of the profile used to store the session credentials.') do |s|
        self.session_profile = s || SESSION_PROFILE
      end
    end

    def console_option(opts)
      opts.on('-c', '--console',
              'Output session information to the console as environment variables available to export.') do
        self.console = true
      end
    end

    def duration_option(opts)
      opts.on('-d', '--duration DURATION', Integer,
              'Specify the duration the of the token in seconds. (Default 3600)') do |d|
        self.duration = d
      end
    end

    def token_option(opts)
      opts.on('-t', '--token [TOKEN]',
              'Specify the OTP Token to use for creating the session credentials.') do |t|
        self.token = t
      end
    end

    def common_options(opts)
      opts.separator('')
      opts.separator('Common options:')
      opts.on_tail('-h', '--help', 'Show this message.') do
        puts opts
        exit
      end
      opts.on_tail('-v', '--version', 'Show version.') do
        puts SemVer.find.format(+ '%M.%m.%p%s')
        exit
      end
    end

    def validate
      validate_profiles
      validate_output
    end

    def validate_profiles
      raise ArgumentError, 'Profile and Session Profile must be different.' if profile == session_profile
      self.user ||= profile if profile_provided
    end

    def validate_output
      raise ArgumentError, 'Either Console or Session Profile is required.' unless console || session_profile
    end
  end

end
