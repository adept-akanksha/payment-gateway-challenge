module Validators
  class CharityValidator
    attr_reader :charity, :amount, :token, :errors
    TRANSLATION_SCOPE = %w(validators charity)

    def validate?
      validate_token? && validate_amount? && validate_charity?
    end

    def validate_token?
      return true if token.present?
      t("token_not_present") && false
    end

    def validate_charity?
      return true if charity.present?
      t("charity_not_present") && false
    end

    def validate_amount?
      return true if amount.to_f > 20
      error = amount.blank? ? "amount_can_not_be_blank" : "amount_not_valid"
      t(error) && false
    end

    private

    def t(error)
      errors << I18n.t(error, scope: TRANSLATION_SCOPE)
    end
  end
end
