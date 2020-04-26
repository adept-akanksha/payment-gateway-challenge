module Validators
  class CharityValidator
    class CharityValidationException < StandardError; end

    attr_reader :charity, :amount, :token, :errors
    TRANSLATION_SCOPE = %w(validators charity)

    def valid?
      valid_token? && valid_amount? && valid_charity?
    rescue CharityValidationException => e
      false
    end

    def valid_token?
      return true if token.present?
      raise_exception("token_not_present")
    end

    def valid_charity?
      return true if charity.present?
      raise_exception("charity_not_present")
    end

    def valid_amount?
      return true if amount.to_f > 20
      error = amount.blank? ? "amount_can_not_be_blank" : "amount_not_valid"
      raise_exception(error)
    end

    private

    def raise_exception(error)
      errors << I18n.t(error, scope: TRANSLATION_SCOPE)
      raise CharityValidationException.new "Invalid Record"
    end
  end
end
