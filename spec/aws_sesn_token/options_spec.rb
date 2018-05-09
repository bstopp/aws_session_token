# frozen_string_literal: true

require 'spec_helper'

describe AwsSessionToken::Options do

  let(:inst) do
    described_class.new
  end

  let(:demo_creds) do
    Aws::SharedCredentials.new
  end

  describe 'initialize' do
    it 'should default credentials_file' do
      expect(inst.credentials_file).to eq(demo_creds.path)
    end
    it 'should default the profile name' do
      expect(inst.profile).to eq(demo_creds.profile_name)
    end
    it 'should default the session_profile name' do
      expect(inst.session_profile).to eq('session_profile')
    end
    it 'should default the duration' do
      expect(inst.duration).to eq(AwsSessionToken::Options::DURATION)
    end

  end
end