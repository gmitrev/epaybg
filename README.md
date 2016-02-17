# Epaybg
[![Code Climate](https://codeclimate.com/github/gmitrev/epaybg.png)](https://codeclimate.com/github/gmitrev/epaybg)
[![Build Status](https://travis-ci.org/gmitrev/epaybg.png?branch=master)](https://travis-ci.org/gmitrev/epaybg)

Rails-specific library for working with the Epay.bg API. More information at
https://demo.epay.bg/?page=login

## Installation

Add this line to your application's Gemfile:

    gem 'epaybg'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install epaybg

## Configuration

Create the config file config/epaybg.yml with the following contents:

```yml
production:
  secret: YOUR-SECRET-KEY
  min: YOUR-MIN
  url: "https://epay.bg"
  url_idn: "https://epay.bg/ezp/reg_bill.cgi"

test:
  secret: YOUR-SECRET-KEY
  min: YOUR-MIN
  url: "https://demo.epay.bg"
  url_idn: "https://demo.epay.bg/ezp/reg_bill.cgi"
```

Set the mode to production in your config/environments/production.rb file:

```ruby
# Add to bottom of the file
Epaybg.mode = :production
```

## Usage
Handle a response callback from epay:

```ruby
response = Epaybg::Response.new(params[:encoded], params[:checksum])
response.valid?
# => true

response.status
# => "PAID"
```

Respond to their callback:
```ruby
response = Epaybg::Response.new(params[:encoded], params[:checksum])

response.invoice
=> "f5b1eaf"

response.response_for(:ok)
=> "INVOICE=f5b1eaf:STATUS=PAID"
```
## Recurring payments

There is no testing environment, so we have to implement this without it.

Also you have to call/email them and ask for the technical specification, because it can not be found on their site.

### Workflow of the feature

If our application has a subscription feature, we may consider implementing recurrent payments.
EpayBG have a rather strange way of doing this.

Here are the steps in their recurring payment cycle.

 - Your user subscribes or makes a purchase on your site/application.
 - You provide them with an unique 'subscription' number.
 - The user registrates this number with EpaBG.
 - From now on every month EpayBG will 'ask' your application(on a tcp server provided by you, which is explained in this readme), if the registreded subscription has any debts with your.
 - Your application searches for a debt related to the number and returns an answer.
 - If a debt is returned, the user will receive notifications from EpayBG, that there is a pending payment.
 - The user payes this pending payment(debt).
 - On the tcp server we will then receive a payment notification, process it and return a response to EpayBG.
 - The next month we will get an other 'debt request' for this number.

It is rather hard to find this information anywhere in the web. Event the documentation EpayBG sends to the developers, is unclear on, how to implement the feature.
After a few days of phone conversations and emails will do the trick, but this can save you some time.

In order to accept recurring payment we have to implement a TCP server.

Here is an example tcp server for accepting incoming tcp requests.

````ruby
require 'socket' # We use ruby`s socket native library.

server = TCPServer.new 2000 # Initialize a TCP server on port 2000 
puts 'Server started on port 2000'

loop do # We start an infinite loop, which will accept the incoming tcp connections.
  Thread.start(server.accept) do |client| # For every request we start a new thread. The code in this block has to be simple and threadsafe.
    begin
      message = client.read # This line will read the incoming data stream until, the tcp client on the other side send a 'shutdown' message.

      # Handel the payment.

    rescue => e
      # Here we can log the error.
    ensure
      client.close
    end
  end
end
````

This is a simple example of a TCP server with rubys 'socket' library. 

### Handling debt requests

The example will work with the TCP server implementation, described in this README.

When EpayBG sends a debt request, they open a TCP connection to the provided server and port.

Then they send a collection of messages divide by new lines '\n'.

After that they stop sending data and now only wait for a response in the same TCP session.

This is and example debt request:

XTYPE=QBN  
AID=700021  
ACSID=0000900  
BORIKAID=0000900  
CLIENTID=67600000000000000  
LANG=1  
IDN=000000000001  
TID=20111010103406700021592704  

Refer to the technical documentation, for further details.

Now that we know, how they send the data, we can handle a request.

First we fetch the request.

````ruby
# ..

message = client.read 
````
This why we get the whole request as a string divided by new lines. The gem provides an method which turns this message into a hash.

````ruby
# ...

data = Epaybg::Recurring.parse_request_body(message)
````

After we have a hash, we can initialize a request object.

````ruby
# ...

request = Epaybg::Recurring::Debt::Request.new data
````
After we do the processing of the request and find out that this number has a pending payment, we have to build the a response object.

This is done through a Epaybg::Recurring::Debt::Request object. It accepts a hash with parameters, validates them and builds a response array.

````ruby
# ...

subscription = Subscription.find_by_epay_number request.idn # We have a payment/subscription registrated with EpayBG

response_params = {
  xvalidto: ( Time.now + 5.days ), # Due date of the subscription.
  secondid: 45, # Custom id for this debt. Optional.
  amount: 5000, # Debt in coins(bulgarian stotinki)
  status: '00', # Status codes accepted by EpayBG, if the status is not '00'(debt found) the other fields will be ignored. Look up the documentation for the other status codes.
  shortdesc: 'Debt description.',
  longdesc: 'Debt details.' # Optional
}

response = Epaybg::Recurring::Debt::Response.new response_params
```` 

Now that we have a response object, we can send back an answer in the current tcp session.
````ruby
  response.body_array.each do |element|
    client.puts element.encode('cp1251') # EpayBG requires the responses in windows-1251 encoding.
  end
````

We have notified EpayBG, that this subscription has a pending payment. Now we wait for a payment request.

### Payments

After the user payes his/her debt through EpayBGs system, they will send us a payment notification on the same TCP server, we user for debt request processing.

This is an example of a payment request.

XTYPE=QBC  
AID=700021  
ACSID=0000900  
BORIKAID=0000900  
CLIENTID=67600000000000000  
IDN=000000000001  
NEWAMOUNT=000000003000  
AMOUNT=5000  
TID=20111010103406700021592705  
REF=592460592460  
TDATE=20111010103409  

We tell the different request by the XTYPE parameter apart. Refer to the technical documentation, for further details.

````ruby 
# ...

epay_recurrent_payment = Epaybg::Recurring::Payment.new data # We fetch the data the same way, as in the previous example.
# Handle the payment logic(mark the subscription as payed)

epay_recurrent_payment.respond_with(:ok) # This will generate a response for this session.

epay_recurrent_payment.response_array.each do |element|
  client.puts element
end
````
We have accepted the payment and notified EpayBG that this payment, has been processed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
