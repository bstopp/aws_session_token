# frozen_string_literal: true

#
# AWS Session Token Gem - Tool to wrap AWS API to create and store Session tokens
# so that other commands/tools (e.g. Terraform) can function as necessary
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

require 'spec_helper'

describe AwsSessionToken::Options, :isolated_environment do

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  subject(:options) { described_class.new }

  let(:demo_creds) do
    Aws::SharedCredentials.new
  end

  describe 'initialize' do
    it 'should default credentials_file' do
      expect(options.credentials_file).to eq(demo_creds.path)
    end
    it 'should default the profile name' do
      expect(options.profile).to eq(demo_creds.profile_name)
    end
    it 'should default the session_profile name' do
      expect(options.session_profile).to eq('session_profile')
    end
    it 'should default the duration' do
      expect(options.duration).to eq(AwsSessionToken::Options::DURATION)
    end
  end

  describe 'options' do
    describe '-h/--help' do
      it 'exits cleanly' do
        expect { options.parse ['-h'] }.to exit_with_code(0)
        expect { options.parse ['--help'] }.to exit_with_code(0)
      end

      it 'shows help text' do
        begin
          options.parse(['--help'])
        rescue SystemExit # rubocop:disable Lint/HandleExceptions
        end

        expected = <<~HELP
          Usage: aws_sesson_token [options]

              -f, --file FILE                  Specify a custom credentials file.
              -u, --user USER                  Specify the AWS User name for passing to API.
              -p, --profile PROFILE            Specify the AWS credentials profile to use. Also sets user, if user is not provided.
              -s, --session SESSION_PROFILE    Specify the name of the profile used to store the session credentials.
              -d, --duration DURATION          Specify the duration the of the token in seconds. (Default 3600)
              -t, --token TOKEN                Specify the OTP Token to use for creating the session credentials.

          Common options:
              -h, --help                       Show this message.
              -v, --version                    Show version.
        HELP
        expect($stdout.string).to eq(expected)
      end
    end

    describe '-v/--version' do
      it 'exits cleanly' do
        expect { options.parse(['-h']) }.to exit_with_code(0)
        expect { options.parse(['--help']) }.to exit_with_code(0)
      end
      it 'shows version' do
        begin
          options.parse(['--version'])
        rescue SystemExit # rubocop:disable Lint/HandleExceptions
        end
        expected = SemVer.find.format(+ '%M.%m.%p%s')
        expect($stdout.string.chomp).to eq(expected)
      end
    end

    describe '-f/--file' do
      it 'fails if no argument' do
        expect { options.parse(['-f']) }.to raise_error(OptionParser::MissingArgument)
        expect { options.parse(['--file']) }.to raise_error(OptionParser::MissingArgument)
      end
      it 'succeeds with an argument' do
        expect { options.parse(%w[-f /foo/bar]) }.to_not raise_error(OptionParser::MissingArgument)
        expect { options.parse(%w[--file /foo/bar]) }.to_not raise_error(OptionParser::MissingArgument)
      end
    end

    describe '-p/--profile' do
      it 'fails if no argument' do
        expect { options.parse(['-p']) }.to raise_error(OptionParser::MissingArgument)
        expect { options.parse(['--profile']) }.to raise_error(OptionParser::MissingArgument)
      end
      it 'succeeds with an argument' do
        expect { options.parse(%w[-p foo]) }.to_not raise_error(OptionParser::MissingArgument)
        expect { options.parse(%w[--profile foo]) }.to_not raise_error(OptionParser::MissingArgument)
      end
    end

    describe '-u/--user' do
      it 'fails if no argument' do
        expect { options.parse(['-u']) }.to raise_error(OptionParser::MissingArgument)
        expect { options.parse(['--user']) }.to raise_error(OptionParser::MissingArgument)
      end
      it 'succeeds with an argument' do
        expect { options.parse(%w[-u foo]) }.to_not raise_error(OptionParser::MissingArgument)
        expect { options.parse(%w[--user foo]) }.to_not raise_error(OptionParser::MissingArgument)
      end
    end

    describe '-s/--session' do
      it 'fails if no argument' do
        expect { options.parse(['-s']) }.to raise_error(OptionParser::MissingArgument)
        expect { options.parse(['--session']) }.to raise_error(OptionParser::MissingArgument)
      end
      it 'succeeds with an argument' do
        expect { options.parse(%w[-s bar]) }.to_not raise_error(OptionParser::MissingArgument)
        expect { options.parse(%w[--session bar]) }.to_not raise_error(OptionParser::MissingArgument)
      end
    end

    describe '-d/--duration' do
      it 'fails if no argument' do
        expect { options.parse(['-d']) }.to raise_error(OptionParser::MissingArgument)
        expect { options.parse(['--duration']) }.to raise_error(OptionParser::MissingArgument)
      end
      it 'fails if argument is not an integer' do
        expect { options.parse(%w[-d abc]) }.to raise_error(OptionParser::InvalidArgument)
        expect { options.parse(%w[--duration abc]) }.to raise_error(OptionParser::InvalidArgument)
      end
      it 'succeeds if argument is an integer' do
        expect { options.parse(%w[-d 1800]) }.to_not raise_error
        expect { options.parse(%w[--duration 1800]) }.to_not raise_error
      end
    end

    describe '-t/--token' do
      it 'succeeds with optional argument' do
        expect { options.parse(['-t']) }.to raise_error(OptionParser::MissingArgument)
        expect { options.parse(['--token']) }.to raise_error(OptionParser::MissingArgument)
      end
      it 'succeeds with an argument' do
        expect { options.parse(%w[-t 123456]) }.to_not raise_error
        expect { options.parse(%w[--token 123456]) }.to_not raise_error
      end
    end

    describe 'validate' do
      it 'does not allow -p & -s' do
        expect { options.parse(%w[-p default -s default]) }.to raise_error(ArgumentError)
      end
      it 'defaults profile attr to user if unspecified' do
        options.parse(%w[-p foo])
        expect(options.profile).to eq(options.user)
      end
    end
  end
end
