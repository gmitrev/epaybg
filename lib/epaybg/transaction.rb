require 'net/http'

module Epaybg

  class Transaction

    attr_accessor :url, :url_idn, :invoice, :amount, :expires_on,
      :description, :encoding, :url_ok, :url_cancel

    def initialize
      set_defaults!
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
      uri = URI "#{@url_idn}/?ENCODED=#{self.encoded}&CHECKSUM=#{self.checksum}"

      http             = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res              = http.get(uri.request_uri)
      res.body
    end

    private

    def validate!
      [:invoice, :amount, :expires_on].each do |a|
        raise ArgumentError, "Missing requried attribute: #{a}" if self.send(a).blank?
      end
    end

    def set_defaults!
      @encoding ||= 'utf-8'
      @url ||= "https://demo.epay.bg"
      @url_idn ||= "https://demo.epay.bg/ezp/reg_bill.cgi"
    end

  end

end
