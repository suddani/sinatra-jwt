# frozen_string_literal: true

module Sinatra
  module Jwt
    class DummyHashDiff
      def self.added_attr_or_appended?(_request_hash, _required_hash)
        raise JwtRequiredDataError, "No diffing implemented"
      end
    end
  end
end
