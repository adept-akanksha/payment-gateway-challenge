class DonationService < Validators::CharityValidator
  attr_reader :charge

  def initialize(options = {})
    @charity = set_charity(options[:charity])
    @token = options[:omise_token]
    @amount = options[:amount]
    @errors = []
  end

  def process
    if valid?
      process_charge
      process_credit_amount
    else
      @token = get_retrieve_token
    end
  end

  def formatted_amount
    Money.new(charge.amount, Charity::DEFAULT_CURRENCY).format
  end

  private

  def set_charity(charity)
    charity == 'random' ? Charity.random_charity : Charity.find_by(id: charity)
  end

  def get_retrieve_token
    Omise::Token.retrieve(token) if token.present?
  end

  def process_charge
    @charge = Omise::Charge.create({
      amount: (amount.to_f * 100).round,
      currency: "THB",
      card: token,
      description: "Donation to #{charity.name} [#{charity.id}]",
    })
  end

  def process_credit_amount
    charity.credit_amount(charge.amount) && return if charge.paid
    errors << I18n.t('website.donate.failure')
    @token = nil
  end
end
