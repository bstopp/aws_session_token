# frozen_string_literal: true

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
