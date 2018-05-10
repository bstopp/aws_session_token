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

  let(:options) do
    described_class.new
  end

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

              -f, --file [FILE]                Specify a custom credentials file.
              -p, --profile [PROFILE]          Specify the AWS credentials profile to use.
              -s, --session [SESSION_PROFILE]  Specify the name of the profile used to store the session credentials.
              -d, --duration [DURATION]        Specify the duration the of the token in seconds. (Default 3600)

          Common options:
              -h, --help                       Show this message.
              -v, --version                    Show version.
        HELP
        expect($stdout.string).to eq(expected)
      end
    end
  end
end
