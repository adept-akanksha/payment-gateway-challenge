class Charity < ActiveRecord::Base
  validates :name, presence: true

  DEFAULT_CURRENCY = 'THB'

  def credit_amount(amount)
    self.with_lock { update_column :total, total + amount }
  end

  def self.random_charity
    Charity.order(Arel.sql("RANDOM()")).first
  end
end
