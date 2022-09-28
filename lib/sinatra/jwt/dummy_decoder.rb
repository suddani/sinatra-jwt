# frozen_string_literal: true

module Sinatra
  module Jwt
    class DummyDecoder
      # rubocop:disable Style/OptionalBooleanParameter
      def self.decode(token, _key = nil, _verify = false, _options = {})
        raise JwtDummyDecoderError, "DummyDecoder should not be used in production" if ENV["RACK_ENV"] != "development"

        encoded_header, encoded_payload, _signature = token.split(".")
        [JSON.parse(Base64.decode64(encoded_payload)), JSON.parse(Base64.decode64(encoded_header))]
      rescue StandardError
        raise JwtDecodingError, "Decoding error"
      end
      # rubocop:enable Style/OptionalBooleanParameter
    end
  end
end
