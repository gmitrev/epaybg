require 'epaybg/railtie'
require 'epaybg/transaction'
require 'epaybg/response'
require "epaybg/version"

module Epaybg

  mattr_accessor :config, :url

  class << self

    def hmac(data)
      OpenSSL::HMAC.hexdigest('sha1', config["secret"], data)
    end

  end
end
