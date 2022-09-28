[![GitHub version](https://badge.fury.io/gh/suddani%2Fsinatra-jwt.svg)](https://badge.fury.io/gh/suddani%2Fsinatra-jwt)
[![Gem Version](https://badge.fury.io/rb/sinatra-jwt.svg)](https://badge.fury.io/rb/sinatra-jwt)

# Sinatra::Jwt

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/sinatra/jwt`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add sinatra-jwt

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install sinatra-jwt

## Usage

```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt
end
```

## Use a single key
If you wish to use a single key you can provide it directly
```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwt_auth "superSecretKey", "HS512"
end
```

## Use a JWK
By default the extension will try to load a file called `jwk.json` from the current path containing the keys if `jwt_auth` was not called with a key.

You should keep in mind that if you are using jwk the header portion of the jwt **has to contain the key id**:
```json
{
  ...
  "kid": "lol"
}
```
An example JWT: 

`eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCIsImtpZCI6ImxvbCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMiwicmlnaHRzIjpbInJlYWRfYXBpIl19.RxOADRpmII2n14Och-34c0w-3NgB74kRi_XgERkO4joiDKYesSZnopL_yMtzVqdkHtLGS_SlULQjudEeQ7q9eg`

that contains the following data:

**HEADER**
```json
{
  "alg": "HS512",
  "typ": "JWT",
  "kid": "lol"
}
```

**PAYLOAD**
```json
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true,
  "iat": 1516239022,
  "rights": ["read_api"]
}
```

An example jwk file containing the key could look like this:
```json
{
  "keys": [
    {
      "kid": "lol",
      "k": "superSecretKey",
      "kty": "oct"
    }
  ]
}
```
The file can contain as many keys as you want all with different algorithms.

### Configure JWK loading


#### Files
You can change the file that is loaded by either hardcoding the path
```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwk_file "/path/to/jwk/file.json"
end
```
or using the env helper method that takes the path from the environment variables
```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwk_file_env "JWK"
  # is equivalent to:
  # jwk_file ENV["JWK"]
end
```

#### Strings
You can change the file that is loaded by either hardcoding the path
```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwk_string '{"keys":[{"kid":"lol","k":"superSecretKey","kty":"oct"}]}'
end
```
or using the env helper method that takes the path from the environment variables
```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwk_string_env "JWK"
  # is equivalent to:
  # jwk_string ENV["JWK"]
end
```


## Protect a route

### Require a valid jwt

```ruby
get "/protected", :auth => true do
  "Hello world login"
end
```

### Allow hitting the next matching url

```ruby
get "/protected", :auth => [{next: true}] do
  "Hello world login"
end

get "/protected" do
  "Hello world login"
end
```

### Require a valid jwt as well as specific payload

```ruby
jwt_data_contains_diff Sinatra::Jwt::TopLevelKeyArrayDiff

get "/protected", :auth => [{contains: {rights: ["read_api"]}}] do
  "Hello world login"
end
```

### TopLevelKeyArrayDiff
The TopLevelKeyArrayDiff only works on a simple top level and array diff level.

So only:
```ruby
{
  "SOMEKEY": "SOMEVALUE can be array, object, string, number etc"
}
```
If the value is an array it can also detect if required attributes are in the array. For any other value type it will cause a missing rights error if the objects are not identical.

## Custom Decoder
You can use a custom decoder by implementing an object that has a `decode` method following the signature of the jwt gem https://github.com/jwt/ruby-jwt

```ruby
require "base64"
require "json"
require "sinatra-jwt"

class DummyDecoder
  def self.decode(token, key = nil, verify = false, options = {})
    raise Sinatra::Jwt::JwtDummyDecoderError, "DummyDecoder should not be used in production" if ENV["RACK_ENV"] != "development"
    encoded_header, encoded_payload, signature = token.split(".")
    [JSON.parse(Base64.decode64(encoded_payload)), JSON.parse(Base64.decode64(encoded_header))]
  end
end

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwt_decoder DummyDecoder

  get "/protected", :auth => true do
    puts jwt_payload
    "Hello world login"
  end
end
```

This decoder is bundled with the extension but will cause `unauthorized calls in any other environment than development`

```ruby
require "sinatra-jwt"

class Application < Sinatra::Base
  register Sinatra::Jwt

  jwt_decoder Sinatra::Jwt::DummyDecoder

  get "/protected", :auth => true do
    puts jwt_payload
    "Hello world login"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/suddani/sinatra-jwt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/suddani/sinatra-jwt/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sinatra::Jwt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/suddani/sinatra-jwt/blob/master/CODE_OF_CONDUCT.md).
