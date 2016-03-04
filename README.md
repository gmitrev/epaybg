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

Create the config file `config/epaybg.yml` with the following contents:

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

Set the mode to production in your `config/environments/production.rb` file:

```ruby
# Add to bottom of the file
Epaybg.mode = :production
```

## Usage
Handle a response callback from EpayBG:

```ruby
response = Epaybg::Response.new params[:encoded], params[:checksum]
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

There is no testing environment. You're on your own.

Your best bet is to contact EpayBG and ask for the technical specification because it can not be
found on their site.

### Workflow

If your application has a subscription feature, you may consider implementing recurrent payments.
EpayBG has a rather strange way of doing this.

Here are the steps in their recurring payment cycle.

 - Your user subscribes or makes a purchase.
 - You provide them with an unique 'subscription' number.
 - The user registers this number with EpayBG.
 - From now on, every month EpayBG will 'ask' your application
    (on a TCP server provided by you, explained below), if the registered
    subscription has any outstanding debts.
 - Your application searches for a debt related to the number and returns an answer.
 - If a debt is returned, the user will receive a notification from EpayBG that there
   is a pending payment.
 - The user pays this pending payment.
 - On the TCP server you will then receive a payment notification, process it and return
   a response to EpayBG.
 - The next month you will get another 'debt request' for this number.

It is rather hard to find this information anywhere in the web. It's unclear even in the official
documentation that
EpayBG send to the developers.

### Implementing a TCP server

In order to accept recurring payment you have to implement a TCP server.

Here is an example server for accepting incoming TCP requests.

````ruby
require 'socket'

server = TCPServer.new 2000

loop do
  #  The code in this block has to be threadsafe
  Thread.start(server.accept) do |client|
    begin
      # This line will read the incoming data stream until the tcp client on the other side sends a
      # 'shutdown' message.
      message = client.read

      # Handle the payment.
    rescue => e
      # Handle an unexpected error
    ensure
      client.close
    end
  end
end
````

### Handling debt requests

The example will work with the TCP server implementation described above.
EpayBG sends a list of messages separated by new lines `\n`.
After that they stop sending data and now only wait for a response in the same TCP session.

#### An example request

```
XTYPE=QBN
AID=700021
ACSID=0000900
BORIKAID=0000900
CLIENTID=67600000000000000
LANG=1
IDN=000000000001
TID=20111010103406700021592704
```

Refer to the technical documentation for further details.

#### Handling the request

The gem provides a method which turns the message into a hash.

````ruby
message = client.read
data = Epaybg::Recurring.parse_request_body(message)
request = Epaybg::Recurring::Debt::Request.new data
````

After you do the processing of the request and find out that this number has a pending payment,
you have to build a response object.

This is done through a Epaybg::Recurring::Debt::Request object. It accepts a hash with parameters,
validates them and builds a response array.

````ruby
# ...

subscription = Subscription.find_by_epay_number request.idn

response_params = {
  xvalidto: (Time.now + 5.days), # Due date of the subscription
  secondid: 45, # Custom id for this debt (Optional)
  amount: 5000, # Debt in coins (bulgarian stotinki)
  status: '00', # If the status is not '00' (debt found) the other fields will be ignored.
                # Look up the documentation for the other status codes.
  shortdesc: 'Debt description',
  longdesc: 'Debt details' # Optional
}

response = Epaybg::Recurring::Debt::Response.new response_params
````

Now that you have a response object, you can send back an answer in the current TCP session.

````ruby
  response.body_array.each do |element|
    client.puts element.encode('cp1251') # EpayBG requires that responses are windows-1251 encoded
  end
````

We have notified EpayBG that this subscription has a pending payment. Now we wait for a payment
request.

### Payments

After the user pays their debt through EpayBG's system, EpayBG will send a payment notification on
the same TCP server used for debt request processing.

This is an example payment request:

```
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
```

Different request types are identified by the `XTYPE` parameter. Refer to the technical
documentation for further details.

````ruby
message = client.read
data = Epaybg::Recurring.parse_request_body(message)
epay_recurrent_payment = Epaybg::Recurring::Payment.new data

# Handle the payment

epay_recurrent_payment.respond_with(:ok) # This will generate a response for this session.

epay_recurrent_payment.response_array.each do |element|
  client.puts element
end
````

The payment is accepted and EpayBG has been notified that the payment has been
processed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
