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
