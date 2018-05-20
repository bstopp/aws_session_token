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

  # Helper class for interacting with the Credentials file.
  class CredentialsFile

    Profile = Struct.new(:name, :data)

    def write(filename, profile, credentials)
      file = nil
      begin
        profiles = read_profiles(filename)
        file = File.open(filename, 'w')
        write_file(credentials, file, profile, profiles)
      ensure
        file&.close
      end
    end

    private

    def read_profiles(credentials_file)
      profiles = []
      profile = nil
      File.readlines(credentials_file).each do |line|
        if line =~ /^\[/
          profile = Profile.new(line, [])
          profiles << profile
        else
          profile.data << line
        end
      end
      profiles
    end

    def write_file(credentials, file, profile, profiles)
      found = false
      profiles.each do |p|
        if p.name =~ /^\[#{profile}\]/
          write_session(file, profile, credentials)
          found = true
        else
          write_profile(file, p)
        end
      end
      write_session(file, profile, credentials) unless found
    end

    def write_profile(file, profile)
      file.puts(profile.name)
      profile.data.each do |l|
        file.puts(l)
      end
    end

    def write_session(file, profile, creds)
      file.puts("[#{profile}]")
      file.puts("aws_access_key_id = #{creds.access_key_id}")
      file.puts("aws_secret_access_key = #{creds.secret_access_key}")
      file.puts("aws_session_token = #{creds.session_token}")
    end
  end
end
