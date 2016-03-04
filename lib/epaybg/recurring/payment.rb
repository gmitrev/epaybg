module Epaybg
  module Recurring
    class Payment

      RESPONSE_STATUS_CODES = {
        ok: '00',
        err: '96',
        duplicate: '94'
      }

      attr_accessor :xtype, :idn, :tid, :amount, :secondid, :ref, :aid, :tdate, :clientid

      def initialize(params = {})
        params.each do |k, v|
          instance_variable_set("@#{k}", v)
        end

        yield self if block_given?
      end

      def respond_with(symbol)
        raise 'Invalid symbol' unless RESPONSE_STATUS_CODES.keys.include?(symbol)

        code = RESPONSE_STATUS_CODES[symbol]
        @response = "XTYPE=RBC\nSTATUS=#{code}\n"
      end

      def response_array
        @response.split("\n")
      end

      def tdate
        Date.parse(@tdate)
      end
    end
  end
end
