require 'epaybg/railtie'
require 'epaybg/transaction'
require 'epaybg/response'
require 'epaybg/version'

module Epaybg
  class << self
    def hmac(data)
      OpenSSL::HMAC.hexdigest('sha1', config['secret'], data)
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
