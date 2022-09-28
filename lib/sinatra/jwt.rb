# frozen_string_literal: true

require "sinatra/base"
require "jwt"

require_relative "jwt/dummy_decoder"
require_relative "jwt/dummy_hash_diff"
require_relative "jwt/helpers"
require_relative "jwt/jwk_loader"
require_relative "jwt/top_level_key_array_diff"
require_relative "jwt/version"

module Sinatra
  module Jwt
    class JwtRequiredDataError < StandardError; end
    class JwtDummyDecoderError < StandardError; end
    class JwtDecodingError < StandardError; end
    class JwtMissingError < StandardError; end
    class JwkLoadError < StandardError; end

    def jwk_file(path = nil)
      set :jwt_auth_jwk_loader, JwkLoader::File.new(path)
      set :jwt_auth_key, nil
    end

    def jwk_string(content)
      set :jwt_auth_jwk_loader, JwkLoader::String.new(content)
      set :jwt_auth_key, nil
    end

    def jwk_file_env(name)
      set :jwt_auth_jwk_loader, JwkLoader::EnvFile.new(name)
      set :jwt_auth_key, nil
    end

    def jwk_string_env(name)
      set :jwt_auth_jwk_loader, JwkLoader::EnvString.new(name)
      set :jwt_auth_key, nil
    end

    def jwt_data_contains_diff(differ)
      set :jwt_auth_auth_diff, differ
    end

    def jwt_auth(key, algorithm = "HS512")
      set :jwt_auth_key, key
      set :jwt_auth_algorithm, algorithm
    end

    def jwt_decoder(decoder)
      set :jwt_auth_decoder, decoder
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def self.registered(app)
      app.helpers Helpers

      app.set :jwt_auth_decoder, JWT
      app.set :jwt_auth_key, nil
      app.set :jwt_auth_algorithm, "HS512"
      app.set :jwt_auth_allowed_algorithms, %w[HS512 RS512]
      app.set :jwt_auth_allowed_algorithms, %w[HS512 RS512]
      app.set :jwt_auth_jwk_loader, JwkLoader::File.new
      app.set :jwt_auth_auth_diff, DummyHashDiff

      app.set(:auth) do |options_data|
        condition do
          return true if options_data == false

          options = options_data.is_a?(Hash) ? options_data : {}
          should_stop = !options.key?(:next) || !options[:next]
          decoded_key = if should_stop
                          authorize!
                        else
                          authorize
                        end

          return false unless decoded_key

          if options.key?(:contains)
            added_keys = settings.jwt_auth_auth_diff.added_attr_or_appended?(
              decoded_key.first,
              JSON.parse(options[:contains].to_json)
            )
            if should_stop && added_keys
              halt 401, { status: "Unauthorized", message: "Missing rights" }.to_json if should_stop && added_keys
            elsif added_keys
              return false
            end
          end
        end
      end

      app.error JwtRequiredDataError, JwtMissingError do |e|
        halt 401, { status: "Unauthorized", message: e.message }.to_json
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
