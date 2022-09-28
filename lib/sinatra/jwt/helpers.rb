# frozen_string_literal: true

module Sinatra
  module Jwt
    module Helpers
      def authorization_token_string
        @authorization_token_string ||= request.env["HTTP_AUTHORIZATION"]
      end

      def authorization_token
        @authorization_token ||= authorization_token_string.split("Bearer ").last
      rescue StandardError
        raise JwtMissingError, "Missing JWT"
      end

      def jwt_decode_options
        if settings.jwt_auth_key.nil?
          {
            algorithms: settings.jwt_auth_allowed_algorithms,
            jwks: settings.jwt_auth_jwk_loader
          }
        else
          {
            algorithm: settings.jwt_auth_algorithm
          }
        end
      end

      def jwt
        @jwt ||= settings.jwt_auth_decoder.decode(
          authorization_token, settings.jwt_auth_key, true, jwt_decode_options
        )
      end

      def jwt_payload
        jwt.first
      end

      def jwt_header
        jwt.last
      end

      def authorize!
        jwt
      rescue StandardError => e
        halt 401, { status: "Unauthorized", message: e.message }.to_json
      end

      def authorize
        jwt
      rescue StandardError => e
        logger&.info({ status: "Unauthorized", message: e.message }.to_json)
        false
      end
    end
  end
end
