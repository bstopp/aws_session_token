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

RSpec::Matchers.define :exit_with_code do |code|
  supports_block_expectations

  actual = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual && actual == code
  end

  failure_message do
    "expected block to call exit(#{code}) but exit" +
      (actual.nil? ? ' not called' : "(#{actual}) was called")
  end

  failure_message_when_negated do
    "expected block not to call exit(#{code})"
  end

  description do
    "expect block to call exit(#{code})"
  end
end
