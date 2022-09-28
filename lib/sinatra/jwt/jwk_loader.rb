# frozen_string_literal: true

module Sinatra
  module Jwt
    module JwkLoader
      class Loader
        def load
          raise StandardError, "Jwk load is not implemented"
        end

        def call(options = {})
          if options[:kid_not_found] && @cache_last_update < Time.now.to_i - 300
            logger.info("Invalidating JWK cache. #{options[:kid]} not found from previous cache")
            @cached_keys = nil
          end
          @cached_keys ||= begin
            @cache_last_update = Time.now.to_i
            load
          end
        rescue StandardError
          raise JwkLoadError, "Could not load the jwk file"
        end
      end

      class File < Loader
        attr_reader :path

        def initialize(path = nil)
          @path = path || "jwk.json"
          super()
        end

        def load
          JSON.parse(::File.read(path))
        end
      end

      class String < Loader
        attr_reader :content

        def initialize(content = nil)
          @content = content || "{}"
          super()
        end

        def load
          JSON.parse(content)
        end
      end

      class EnvString < String
        def initialize(name = nil)
          super(ENV.fetch(name, nil))
        end
      end

      class EnvFile < File
        def initialize(name = nil)
          super(ENV.fetch(name, nil))
        end
      end
    end
  end
end
