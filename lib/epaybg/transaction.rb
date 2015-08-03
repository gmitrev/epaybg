require 'net/http'

module Epaybg

  class Transaction

    attr_accessor :url, :url_idn, :invoice, :amount, :expires_on,
      :description, :encoding, :url_ok, :url_cancel

    def initialize(args = {})
      set_defaults!
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
      yield self if block_given?
      validate!
    end

    def encoded
      exp_time = self.expires_on.strftime("%d.%m.%Y")

      data = <<-DATA
MIN=#{Epaybg.config["min"]}
LANG=bg
INVOICE=#{self.invoice}
AMOUNT=#{self.amount}
EXP_TIME=#{exp_time}
      DATA

      Base64.strict_encode64(data)
    end

    def checksum
      Epaybg::hmac(encoded)
    end

    def register_payment
      uri = URI("#{self.url_idn}/?ENCODED=#{self.encoded}&CHECKSUM=#{self.checksum}")

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res              = http.get(uri.request_uri)
      res.body
    end

    def epay_link
      base_link "paylogin"
    end

    def credit_card_link
      base_link "credit_paydirect"
    end

    private

    def base_link(action)
      "#{self.url}/?PAGE=#{action}&ENCODED=#{self.encoded}&CHECKSUM=#{self.checksum}&URL_OK=#{self.url_ok}&URL_CANCEL=#{self.url_cancel}"
    end

    def validate!
      [:invoice, :amount, :expires_on].each do |a|
        raise ArgumentError, "Missing requried attribute: #{a}" if self.send(a).blank?
      end
    end

    def set_defaults!
      @url      ||= Epaybg.config["url"]
      @url_idn  ||= Epaybg.config["url_idn"]
      @encoding ||= 'utf-8'
    end

  end

end
