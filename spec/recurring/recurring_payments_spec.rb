require 'spec_helper'
require 'yaml'

describe 'Recurring Payments' do
  let(:request_string) {
    "XTYPE=QBN\nAID=000100\nACSID=0000897\nBORIKAID=0000897\nCLIENTID=67600000000000000\nIDN=6460392\nTID=20160225080306000100705669\n"
  }

  let(:debt_params){
    Epaybg::Recurring.parse_request_body(request_string)
  }

  before do
    Epaybg.config = YAML.load_file('spec/test_config.yml')
  end

  describe 'Recurring module methods' do
    it 'should parse a request string' do
      expect(debt_params).to be_kind_of Hash
      expect(debt_params['xtype']).to eq 'QBN'
      expect(debt_params['idn']).to eq '6460392'
    end
  end

  describe 'Recurrent payment debt request' do
    it 'should create a valid object' do
      request = Epaybg::Recurring::Debt::Request.new debt_params

      expect(request.xtype).not_to be_nil
      expect(request.idn).not_to be_nil
      expect(request.tid).not_to be_nil
      expect(request.aid).not_to be_nil
      expect(request.clientid).not_to be_nil
    end
  end

  describe 'Recurrent payment debt response' do
    let(:valid_params){
      {
        xvalidto: ( Time.now + 5.days ),
        secondid: 'sid25',
        amount: 5000,
        status: '00',
        shortdesc: 'Some description',
        longdesc: 'Some long description'
      }
    }

    it 'create a valid object' do
      response = Epaybg::Recurring::Debt::Response.new valid_params
      expect(response).to be_valid
      expect(response.body_array).not_to be_empty
    end

    describe 'Invalid objects' do
      it 'should have the right elements' do
        response = Epaybg::Recurring::Debt::Response.new {}
        expect(response).not_to be_valid
      end

      it 'should not have too long messages' do
        invalid_params = {
          shortdesc: "a" * 60,
          longdesc: "b" * 1801,
        }

        response = Epaybg::Recurring::Debt::Response.new(valid_params.merge(invalid_params))
        expect(response).not_to be_valid
      end

      it 'should not accept invalid status codes' do
        invalid_params = {
          status: '1233'
        }
        response = Epaybg::Recurring::Debt::Response.new(valid_params.merge(invalid_params))
        expect(response).not_to be_valid
      end

    end
  end

  describe 'Recurring payment object' do
    let(:valid_params) {
      {
        xtype: 'RBN',
        idn: '0000000001',
        tid: '423423423423423423',
        amount: 5000,
        secondid: 'si45',
        ref: '234234234234234',
        aid: '000100',
        tdate: '20160224173336',
        clientid: '07728424664'
      }
    }

    it 'should create a valid object' do
      payment = Epaybg::Recurring::Payment.new valid_params

      expect(payment.tdate).to be_kind_of(Date)

      expect{ payment.respond_with(:ok) }.not_to raise_error
      expect{ payment.respond_with(:err) }.not_to raise_error
      expect{ payment.respond_with(:duplicate) }.not_to raise_error

      expect{ payment.respond_with(:something_else) }.to raise_error('Invalid symbol')

      expect(payment.respond_with(:ok)).not_to be_nil
    end
  end
end
