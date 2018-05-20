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

require 'spec_helper'
require 'aws_sesn_token/credentials_file'

describe AwsSessionToken::CLI do

  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  subject(:cli) { described_class.new }

  let(:creds_data) do
    Aws::STS::Types::Credentials.new(
      access_key_id:      'AKIAIOSFODNN7EXAMPLE',
      expiration:         Time.parse('2011-07-11T19:55:29.611Z'),
      secret_access_key:  'wJalrXUtnFEMI/K7MDENG/bPxRfiCYzEXAMPLEKEY',
      session_token:      'EXAMPLE SESSION TOKEN'
    )
  end

  let(:mfa_arn) { 'Fake Serial Number' }

  let(:mfa_token) { 123_456 }

  describe 'run' do
    it 'should work' do
      expect(cli).to receive(:set_aws_creds)
      expect(cli).to receive(:mfa_device).and_return(mfa_arn)
      expect(cli).to receive(:token_prompt).and_return(mfa_token)
      expect(cli).to receive(:session_token).with(mfa_arn, mfa_token).and_return(creds_data)
      expect_any_instance_of(AwsSessionToken::CredentialsFile).to receive(:write).with(
        Aws::SharedCredentials.new.path,
        AwsSessionToken::Options::SESSION_PROFILE,
        creds_data
      )
      cli.run
    end

    describe 'token provided' do
      before do
        ARGV << '-t'
        ARGV << mfa_token.to_s
      end

      it 'should skip token prompt' do
        expect(cli).to receive(:set_aws_creds)
        expect(cli).to receive(:mfa_device).and_return(mfa_arn)
        expect(cli).to receive(:session_token).with(mfa_arn, mfa_token).and_return(creds_data)
        expect_any_instance_of(AwsSessionToken::CredentialsFile).to receive(:write).with(
          Aws::SharedCredentials.new.path,
          AwsSessionToken::Options::SESSION_PROFILE,
          creds_data
        )
        cli.run
      end
    end
  end

  describe 'validate_creds_file' do
    it 'should succeed if file exists' do
      creds = Aws::SharedCredentials.new
      expect(File).to receive(:exist?).with(creds.path).and_return(true)
      expect { cli.validate_creds_file }.to_not raise_error
    end

    it 'should fail if file is missing' do
      creds = Aws::SharedCredentials.new
      expect(File).to receive(:exist?).with(creds.path).at_least(:once).and_return(false)
      expect { cli.validate_creds_file }.to raise_error(ArgumentError, /Specified credentials file is missing/)
    end

    it 'should fail if file is not writable by current user' do
      creds = Aws::SharedCredentials.new
      expect(File).to receive(:exist?).with(creds.path).at_least(:once).and_return(true)
      expect(File).to receive(:writable?).with(creds.path).at_least(:once).and_return(false)
      expect { cli.validate_creds_file }.to raise_error(ArgumentError, /Specified credentials file cannot /)
    end
  end

  describe 'set_aws_creds' do
    it 'is should work' do
      expect(Aws.config).to receive(:update).with(
        credentials: instance_of(Aws::SharedCredentials)
      )
      cli.set_aws_creds
    end
    it 'is should fail if profile does not exist' do
      cli.options.profile = 'nonexistent'
      expect { cli.set_aws_creds }.to exit_with_code(1)
      expect($stderr.string).to match(/Specified AWS Profile doesn't exist: nonexistent/)
    end
  end

  describe 'mfa_device' do
    let(:mfa_device) do
      mfa = Aws::IAM::Types::MFADevice.new
      mfa.user_name = 'username'
      mfa.serial_number = 'serial-number'
      mfa.enable_date = 'enable-date'
      mfa
    end

    it 'should work without user' do
      params = { max_items: 1 }
      client = double('iam_client')
      response = Aws::IAM::Types::ListMFADevicesResponse.new(mfa_devices: [mfa_device])
      expect(Aws::IAM::Client).to receive(:new).and_return(client)
      expect(client).to receive(:list_mfa_devices).with(params).and_return(response)
      expect(cli.mfa_device).to eq('serial-number')
    end
    it 'should work with user' do
      cli.options.user = 'foo'
      params = { user_name: 'foo', max_items: 1 }
      client = double('iam_client')
      response = Aws::IAM::Types::ListMFADevicesResponse.new(mfa_devices: [mfa_device])
      expect(Aws::IAM::Client).to receive(:new).and_return(client)
      expect(client).to receive(:list_mfa_devices).with(params).and_return(response)
      expect(cli.mfa_device).to eq('serial-number')
    end
    it 'should exit if no MFA devices' do

      client = double('iam_client')
      response = Aws::IAM::Types::ListMFADevicesResponse.new(mfa_devices: [])
      expect(Aws::IAM::Client).to receive(:new).and_return(client)
      expect(client).to receive(:list_mfa_devices).and_return(response)
      begin
        expect { cli.mfa_device }.to exit_with_code(0)
      rescue SystemExit # rubocop:disable Lint/HandleExceptions
      end
      expected = 'Script execution unnecessary.'
      expect($stderr.string).to match(/#{expected}/)
    end
  end

  context 'token_prompt' do
    before do
      $stdin = StringIO.new
      $stdin.puts('123456')
      $stdin.rewind
    end
    it 'should work' do
      expect { cli.token_prompt }.to_not raise_error
    end
  end

  describe 'session_token' do
    let(:response) do
      creds = Aws::STS::Types::Credentials.new
      creds.access_key_id = 'access_key_id'
      creds.secret_access_key = 'secret_access_key'
      creds.expiration = 'expiration'
      creds.session_token = 'session_token'

      resp = Aws::STS::Types::GetSessionTokenResponse.new
      resp.credentials = creds
      resp
    end

    it 'should work' do
      device = 'device'
      token = 'token'
      client = double('sts-client')
      expect(Aws::STS::Client).to receive(:new).and_return(client)
      expect(client).to receive(:get_session_token).with(
        duration_seconds: 3600, serial_number: device, token_code: token
      ).and_return(response)
      expect(cli.session_token(device, token)).to eq(response.credentials)
    end
  end
end
