[![Gem Version](https://badge.fury.io/rb/aws_session_token.svg)](https://badge.fury.io/rb/aws_session_token)
[![Build Status](https://travis-ci.org/bstopp/aws_session_token.svg?branch=master)](https://travis-ci.org/bstopp/aws_session_token)
[![Maintainability](https://api.codeclimate.com/v1/badges/b3c10a834e5a1498783d/maintainability)](https://codeclimate.com/github/bstopp/aws_session_token/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b3c10a834e5a1498783d/test_coverage)](https://codeclimate.com/github/bstopp/aws_session_token/test_coverage)

# AWS Session Token

This is a utility gem to help users create a temporary Session token. This is useful when accounts have Multi Factor Authentication enabled, and some actions require MFA authentication.

## Installation

Run standard gem installation.

```sh
$ gem install aws_session_token
```

## Compatibility

AWS Session Token is compatible with:

* Ruby 2.3+

## Usage

```
Usage: aws_session_token [options]

    -f, --file FILE                  Specify a custom credentials file.
    -u, --user USER                  Specify the AWS User name for passing to API.
    -p, --profile PROFILE            Specify the AWS credentials profile to use. Also sets user, if user is not provided.
    -s, --session SESSION_PROFILE    Specify the name of the profile used to store the session credentials.
    -d, --duration DURATION          Specify the duration the of the token in seconds. (Default 3600)
    -t, --token TOKEN                Specify the OTP Token to use for creating the session credentials.

Common options:
    -h, --help                       Show this message.
    -v, --version                    Show version.

```

### File
Specifies the AWS Credentials file that will be used to both find the source Profile, and where to write the Session token data.

### User
Specify the AWS User associated with the account. This is necessary if the profile's name is different than the one in AWS (or if you're using the _default_ profile).

This may also be required if AWS Policies prevent the user associated with the credentials from listing all MFA Devices associated with the AWS Account.

### Profile
Used to specify the AWS Profile in the credentials file for authenticating & generating a new session token. Default: `default`.

### Session
Provide the name of the profile to create with the session token credentials. Default: `session_profile`

### Duration
The lifespan of the session token, in seconds. Default: `3600` (1 hour).

### Token
The token from the MFA Device. Can be provided via CLI; if not specified, user will be prompted. 


## Contributing to aws_session_token

-   Check out the latest master to make sure the feature hasn't been
    implemented or the bug hasn't been fixed yet.
-   Check out the issue tracker to make sure someone already hasn't
    requested it and/or contributed it.
-   Fork the project.
-   Start a feature/bugfix branch.
-   Commit and push until you are happy with your contribution.
-   Make sure to add tests for it. This is important so I don't break it
    in a future version unintentionally.
-   Please try not to mess with the Rakefile, version, or history. If
    you want to have your own version, or is otherwise necessary, that
    is fine, but please isolate to its own commit so I can cherry-pick
    around it.

## Copyright

Copyright (c) 2018 Bryan Stopp. See [LICENSE](LICENSE) for further details.
