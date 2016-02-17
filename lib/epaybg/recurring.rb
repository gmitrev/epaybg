require 'epaybg/recurring/payment'
require 'epaybg/recurring/debt/request'
require 'epaybg/recurring/debt/response'


module Epaybg
  module Recurring
    def self.parse_request_body(body)
      # The \s could be replaced with \r but for now i will leave it be
      # It will be changed after we complate some test with EpayBG

      array = body.split(/\s/).reject(&:empty?).compact
      array.inject({}) do |hash, element|
        key, value = *element.strip.split('=')
        hash[key.downcase] = value
        hash
      end
    end
  end
end
