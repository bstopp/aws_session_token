require 'pp'

module AwsSessionToken

  class CLI

    def run
      @options = Options.new
      @options.parse(ARGV)
      update_creds
      mfa_device = get_mfa_device
      token = token_prompt
      @user = get_session_token(mfa_device, token)
    end

    def update_creds
      begin
        credentials = Aws::SharedCredentials.new(path: @options.credentials_file, profile_name: @options.profile)
        Aws.config.update(credentials: credentials)
      rescue Aws::Errors::NoSuchProfileError
        warn "\nSpecified AWS Profile doesn't exist: #{@options.profile}"
        exit
      end
    end

    def get_mfa_device

    end

    def token_prompt
      cli = HighLine.new
      cli.ask "Specify the OTP Token for the profile #{@options.profile}:"
    end

    def get_session_token(creds, otp)
      @sts_client = Aws::STS::Client.new
      @sts_client.get_session_token
    end

    def write_creds

    end
  end
end
