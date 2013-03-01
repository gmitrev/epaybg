$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "action_controller/railtie"
require 'rspec/rails'

RSpec.configure do |config|
end

require 'epaybg'
Epaybg.config = {
  "test" => {"secret"=>"QESI7RA4BCW95TZPH2OM7583DCP250CEVWZYMM69E8GRS38932W54DWYI9KNCMZ0", "min"=>"D760738416", "url"=>"https://demo.epay.bg", "url_idn"=>"https://demo.epay.bg/ezp/reg_bill.cgi"},
  "production" => {"secret"=>"n/a", "min"=>"n/a", "url"=>"https://epay.bg", "url_idn"=>"https://epay.bg/ezp/reg_bill.cgi"}
}
