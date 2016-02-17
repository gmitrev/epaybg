module Epaybg
  module Recurring
    module Debt
      class Request
        attr_accessor :xtype, :idn, :tid, :aid, :clientid 

        def initialize(params = {})
          params.each do |k, v|
            instance_variable_set("@#{k}", v)
          end

          yield self if block_given?
        end
      end
    end
  end
end
