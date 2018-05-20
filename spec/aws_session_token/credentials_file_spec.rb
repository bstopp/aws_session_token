# frozen_string_literal: true

require 'spec_helper'

describe AwsSessionToken::CredentialsFile, :isolated_environment do
  before do
    $stdout = StringIO.new
    $stderr = StringIO.new
  end

  after do
    $stdout = STDOUT
    $stderr = STDERR
  end

  subject(:cf) { described_class.new }

  let(:creds) do
    creds = Aws::STS::Types::Credentials.new
    creds.access_key_id = 'access_key_id'
    creds.secret_access_key = 'secret_access_key'
    creds.expiration = 'expiration'
    creds.session_token = 'session_token'
    creds
  end

  describe 'write' do
    let(:file_contents) do
      <<~CREDS
        [stopp]
        aws_access_key_id = EXAMPLESTOPPACCESSID
        aws_secret_access_key = EXAMPLESTOPPSECRETKEY
        [admin]
        aws_access_key_id = EXAMPLEADMINACCESSID
        aws_secret_access_key = EXAMPLEADMINSECRETKEY
      CREDS
    end

    shared_examples 'update file' do |opts|
      it do
        file = StringIO.new
        default_creds = Aws::SharedCredentials.new
        expect(File).to receive(:readlines).with(default_creds.path).and_return(file_contents.split("\n"))
        expect(File).to receive(:open).with(default_creds.path, 'w').and_return(file)
        cf.write(default_creds.path, opts[:profile], creds)
        expect(file.string).to eq(opts[:expected])
      end
    end

    describe 'profile does not exist' do
      contents = <<~CREDS
        [stopp]
        aws_access_key_id = EXAMPLESTOPPACCESSID
        aws_secret_access_key = EXAMPLESTOPPSECRETKEY
        [admin]
        aws_access_key_id = EXAMPLEADMINACCESSID
        aws_secret_access_key = EXAMPLEADMINSECRETKEY
        [session_profile]
        aws_access_key_id = access_key_id
        aws_secret_access_key = secret_access_key
        aws_session_token = session_token
      CREDS

      it_should_behave_like('update file', expected: contents, profile: 'session_profile')
    end

    describe 'profile exists' do
      describe 'first profile' do
        contents = <<~CREDS
          [stopp]
          aws_access_key_id = access_key_id
          aws_secret_access_key = secret_access_key
          aws_session_token = session_token
          [admin]
          aws_access_key_id = EXAMPLEADMINACCESSID
          aws_secret_access_key = EXAMPLEADMINSECRETKEY
        CREDS

        it_should_behave_like('update file', expected: contents, profile: 'stopp')
      end
      describe 'last profile' do
        contents = <<~CREDS
          [stopp]
          aws_access_key_id = EXAMPLESTOPPACCESSID
          aws_secret_access_key = EXAMPLESTOPPSECRETKEY
          [admin]
          aws_access_key_id = access_key_id
          aws_secret_access_key = secret_access_key
          aws_session_token = session_token
        CREDS
        it_should_behave_like('update file', expected: contents, profile: 'admin')
      end
    end
  end
end
