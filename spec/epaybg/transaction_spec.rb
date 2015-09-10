require 'spec_helper'
require 'yaml'

describe 'Transaction' do
  before {
    Epaybg.config = YAML.load_file('spec/test_config.yml')
  }

  it 'can generate an epay_link for a transaction without using the config' do
    transaction_params_without_config = {
      invoice: 12345,
      amount: 1,
      expires_on: Date.today + 1,
      min: "YOUR-MIN",
      secret: "YOUR-SECRET-KEY",
      url_ok: 'http://www.google.com',
      url_cancel: 'http://www.yahoo.com',
    }

    transaction_params_with_config = {
      invoice: 12345,
      amount: 1,
      expires_on: Date.today + 1,
      url_ok: 'http://www.google.com',
      url_cancel: 'http://www.yahoo.com',
    }

    config_transaction = ::Epaybg::Transaction.new(transaction_params_with_config)
    no_config_transaction = ::Epaybg::Transaction.new(transaction_params_without_config)

    expect(config_transaction.epay_link).to eq(no_config_transaction.epay_link)
  end

  it 'can generate a credit_card_link for a transaction without using the config' do
    transaction_params_without_config = {
      invoice: 12345,
      amount: 1,
      expires_on: Date.today + 1,
      min: "YOUR-MIN",
      secret: "YOUR-SECRET-KEY",
      url_ok: 'http://www.google.com',
      url_cancel: 'http://www.yahoo.com',
    }

    transaction_params_with_config = {
      invoice: 12345,
      amount: 1,
      expires_on: Date.today + 1,
      url_ok: 'http://www.google.com',
      url_cancel: 'http://www.yahoo.com',
    }

    config_transaction = ::Epaybg::Transaction.new(transaction_params_with_config)
    no_config_transaction = ::Epaybg::Transaction.new(transaction_params_without_config)

    expect(config_transaction.credit_card_link).to eq(no_config_transaction.credit_card_link)
  end
end