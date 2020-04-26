require 'minitest/mock'
require "test_helper"

module OmiseMock
  class << self
    def create_charge_request(paid_status = true)
      charge = ->(params) { mock_charge(params[:amount], paid_status) }
      Omise::Charge.stub(:create, charge) { yield }
    end

    def retrieve_token_request
      Omise::Token.stub(:retrieve, mock_token) { yield }
    end

    def mock_charge(amount, paid_status)
      charge_params = { amount: amount, paid: paid_status }
      unless paid_status
        charge_params.merge!(failure_message: "Failed card processing")
      end
      OpenStruct.new(charge_params)
    end

    def mock_token
      OpenStruct.new({
        id: "tokn_X",
        card: OpenStruct.new({
          name: "J DOE",
          last_digits: "4242",
          expiration_month: 10,
          expiration_year: 2020,
          security_code_check: false,
        }),
      })
    end
  end
end
