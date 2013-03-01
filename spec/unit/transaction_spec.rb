require 'spec_helper'

describe Epaybg::Transaction do
  let :attributes do
    { invoice: "12345", amount: 69.99, expires_on: Date.tomorrow  }
  end

  describe "initialization" do
    it "accepts a hash with options" do
      lambda do
        Epaybg::Transaction.new(attributes)
      end.should_not raise_error ArgumentError
    end

    it "accepts a block with options" do
      lambda do
        Epaybg::Transaction.new do |t|
          t.amount = attributes[:amount]
          t.price = attributes[:price]
          t.expires_on = attributes[:expires_on]
        end
      end.should_not raise_error ArgumentError
    end

    it "doesn't initialize without no options" do
      lambda do
        Epaybg::Transaction.new
      end.should raise_error ArgumentError

    end

    [:invoice, :amount, :expires_on].each do |attr|
      it "fails when no #{attr} is given" do
        lambda do
          Epaybg::Transaction.new(attributes.except(attr))
        end.should raise_error ArgumentError
      end
    end
  end
end
