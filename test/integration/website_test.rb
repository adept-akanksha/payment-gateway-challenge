require "test_helper"
require 'omise_mock_helper'

class WebsiteTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get "/"

    assert_response :success
  end

  test "that someone can't donate to no charity" do
    OmiseMock.retrieve_token_request do
      post(donate_path, params: {
             amount: "100", omise_token: "tokn_X", charity: ""
           })

      assert_template :index
      assert_equal t("validators.charity.charity_not_present"), flash.now[:alert]
    end
  end

  test "that someone can't donate 0 to a charity" do
    charity = charities(:children)

    OmiseMock.retrieve_token_request do
      post(donate_path, params: {
             amount: "0", omise_token: "tokn_X", charity: charity.id
           })

      assert_template :index
      assert_equal t("validators.charity.amount_not_valid"), flash.now[:alert]
    end
  end

  test "that someone can't donate less than 20 to a charity" do
    charity = charities(:children)

    OmiseMock.retrieve_token_request do
      post(donate_path, params: {
             amount: "19", omise_token: "tokn_X", charity: charity.id
           })

      assert_template :index
      assert_equal t("validators.charity.amount_not_valid"), flash.now[:alert]
    end
  end

  test "that someone can't donate without a token" do
    charity = charities(:children)
    post(donate_path, params: {
           amount: "100", charity: charity.id
         })

    assert_template :index
    assert_equal t("validators.charity.token_not_present"), flash.now[:alert]
  end

  test "that someone can donate to a charity" do
    charity = charities(:children)
    initial_total = charity.total
    expected_amount = 100 * 100
    expected_total = initial_total + expected_amount

    OmiseMock.create_charge_request do
      post(donate_path, params: {
             amount: "100", omise_token: "tokn_X", charity: charity.id
           })
      follow_redirect!

      assert_template :index
      assert_equal t("website.donate.success",
        amount: formatted_amount(expected_amount)), flash[:notice]
      assert_equal expected_total, charity.reload.total
    end
  end

  test "that if the charge fail from omise side it shows an error" do
    charity = charities(:children)

    OmiseMock.create_charge_request(false) do
      post(donate_path, params: {
             amount: "999", omise_token: "tokn_X", charity: charity.id
           })

      assert_template :index
      assert_equal t("website.donate.failure"), flash.now[:alert]
    end
  end

  test "that we can donate to a charity at random" do
    charities = Charity.all
    initial_total = charities.to_a.sum(&:total)
    expected_amount = 100 * 100
    expected_total = initial_total + expected_amount

    OmiseMock.create_charge_request do
      post(donate_path, params: {
             amount: "100", omise_token: "tokn_X", charity: "random"
           })
      follow_redirect!

      assert_template :index
      assert_equal expected_total, charities.to_a.map(&:reload).sum(&:total)
      assert_equal t("website.donate.success",
        amount: formatted_amount(expected_amount)), flash[:notice]
    end
  end

  test "that someone can't donate blank amount to a charity" do
    charity = charities(:children)

    OmiseMock.retrieve_token_request do
      post(donate_path, params: {
             amount: "", omise_token: "tokn_X", charity: charity.id
           })

      assert_template :index
      assert_equal t("validators.charity.amount_can_not_be_blank"), flash.now[:alert]
    end
  end

  test "that someone can't donate when amount is not given" do
    charity = charities(:children)

    OmiseMock.retrieve_token_request do
      post(donate_path, params: {
            omise_token: "tokn_X", charity: charity.id
           })

      assert_template :index
      assert_equal t("validators.charity.amount_can_not_be_blank"), flash.now[:alert]
    end
  end

  test "that someone can't donate when amount is given in subunits but less than 20" do
    charity = charities(:children)

    OmiseMock.retrieve_token_request do
      post(donate_path, params: {
            amount: "19.01", omise_token: "tokn_X", charity: charity.id
           })

      assert_template :index
      assert_equal t("validators.charity.amount_not_valid"), flash.now[:alert]
    end
  end

  test "that someone can donate to charity with amount in subunits" do
    charity = charities(:children)
    initial_total = charity.total
    expected_amount = (100.25 * 100).round
    expected_total = initial_total + expected_amount

    OmiseMock.create_charge_request do
      post(donate_path, params: {
             amount: "100.25", omise_token: "tokn_X", charity: charity.id
           })
      follow_redirect!

      assert_template :index
      assert_equal t("website.donate.success",
        amount: formatted_amount(expected_amount)), flash[:notice]
      assert_equal expected_total, charity.reload.total
    end
  end

  test "that someone can donate to charity with 20.01 amount" do
    charity = charities(:children)
    initial_total = charity.total
    expected_amount = (20.01 * 100).round
    expected_total = initial_total + expected_amount

    OmiseMock.create_charge_request do
      post(donate_path, params: {
             amount: "20.01", omise_token: "tokn_X", charity: charity.id
           })
      follow_redirect!

      assert_template :index
      assert_equal t("website.donate.success",
        amount: formatted_amount(expected_amount)), flash[:notice]
      assert_equal expected_total, charity.reload.total
    end
  end
end
