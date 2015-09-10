require 'net/http'

module Epaybg
  class Transaction
    attr_accessor :url, :url_idn, :invoice, :amount, :expires_on,
                  :description, :encoding, :url_ok, :url_cancel, :min, :secret

    def initialize(args = {})
      set_defaults!
      args.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
      yield self if block_given?
      validate!
    end

    def encoded
      exp_time = expires_on.strftime('%d.%m.%Y')

      data = <<-DATA
MIN=#{min}
LANG=bg
INVOICE=#{invoice}
AMOUNT=#{amount}
EXP_TIME=#{exp_time}
      DATA

      Base64.strict_encode64(data)
    end

    def checksum
      Epaybg.hmac(encoded, secret)
    end

    def register_payment
      uri = URI("#{url_idn}/?ENCODED=#{encoded}&CHECKSUM=#{checksum}")

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res              = http.get(uri.request_uri)
      res.body
    end

    def epay_link
      base_link 'paylogin'
    end

    def credit_card_link
      base_link 'credit_paydirect'
    end

    private

    def base_link(action)
      "#{url}/?PAGE=#{action}&ENCODED=#{encoded}&CHECKSUM=#{checksum}&URL_OK=#{url_ok}&URL_CANCEL=#{url_cancel}"
    end

    def validate!
      [:invoice, :amount, :expires_on].each do |a|
        raise ArgumentError, "Missing requried attribute: #{a}" if send(a).blank?
      end
    end

    def set_defaults!
      @url ||= Epaybg.config['url']
      @url_idn ||= Epaybg.config['url_idn']
      @encoding ||= 'utf-8'
      @min ||= Epaybg.config['min']
      @secret ||= Epaybg.config['secret']
    end
  end
end
