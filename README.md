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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
