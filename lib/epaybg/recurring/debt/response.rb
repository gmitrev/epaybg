module Epaybg
  module Recurring
    module Debt
      class Response
        attr_accessor :xvalidto, :secondid, :amount, :status, :shortdesc, :longdesc, :errors

        XTYPE = 'RBN'
        STATUSES = %w(00 62 14 80 96)

        # Status codes for epay

        # 00 върнато е задължение / debt returned
        # 62 няма задължение. / no debts for this isd
        # 14 невалиден номер(idn) / invalid idn
        # 80 заявката временно не може да бъде изпълнена / timeout, server buisy
        # 96 обща грешка / other errors

        def initialize(params = {})
          @errors = []

          params.each do |k, v|
            instance_variable_set("@#{k}", v)
          end

          yield self if block_given?
          validate!
        end

        def validate!
          [:xvalidto, :amount, :status, :shortdesc].each do |element|
            @errors << "Attribute #{element} is required!" if send(element).blank?
          end

          @errors << "'xvalidto' should be a time type field!" unless xvalidto.kind_of?(Time)

          {secondid: 15, shortdesc: 40, longdesc: 1800}.each do |k, v|
            @errors << "Attribute #{k} is too long. Maximum length should be #{v}." if send(k).to_s.length > v
          end

          @errors << "Invalid value #{status} for status" unless STATUSES.include?(status)
        end

        def valid?
          @errors.empty?
        end

        def longdesc
          return nil unless @longdesc

          @longdesc.gsub("\n", "\\n")
        end

        def body_array
          @body_array = [
                          "XTYPE=#{XTYPE}",
                          "XVALIDTO=#{xvalidto.strftime('%Y%m%d000000')}",
                          "AMOUNT=#{amount}",
                          "STATUS=#{status}",
                          "SHORTDESC=#{shortdesc}"
                        ]

          @body_array << "SECONDID=#{secondid}" if secondid
          @body_array << "LONGDESC=#{longdesc}" if longdesc
          @body_array
        end

        def body
          body_array.join("\n") + "\n"
        end
      end
    end
  end
end
