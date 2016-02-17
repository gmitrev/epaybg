require 'epaybg/railtie' if defined?(Rails)
require 'epaybg/transaction'
require 'epaybg/response'
require 'epaybg/version'
require 'epaybg/recurring'

module Epaybg
  class << self
    def hmac(data, secret)
      OpenSSL::HMAC.hexdigest('sha1', secret, data)
    end

    # Configuration is loaded based on this property.
    # Values are [:production, :test]. Defaults to :production
    def mode
      @@mode
    end

    def mode=(mode)
      valid = [:test, :production]
      raise ArgumentError, "#{mode} is not a valid mode for Epaybg.
        Valid modes are #{valid}." unless valid.include?(mode)
      @@mode = mode
    end

    @@mode = :test

    # A hash containing the configuration options found in the
    # config/epaybg.yml file.
    def config
      @@config[mode.to_s]
    end

    def config=(config)
      @@config = config
    end
  end
end
