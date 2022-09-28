# frozen_string_literal: true

module Sinatra
  module Jwt
    class TopLevelKeyArrayDiff
      def self.added_attr_or_appended?(request_hash, required_hash)
        return false if request_hash == required_hash

        required_hash.each do |key, value|
          next if request_hash[key] == value
          return true if request_hash[key].nil?

          return true unless (value - request_hash[key]).empty?
        end
        false
      rescue StandardError
        true
      end
    end
  end
end
