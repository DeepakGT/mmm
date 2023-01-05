class ReferralBonus < ApplicationRecord
  include HasCurrency

  belongs_to :pay_in

  enum status: {inactive: 0, active: 1}

  has_many :payments, -> { where(payment_type: Payment.payment_types[:referral_bonus]) }, foreign_key: :activity_id, class_name: 'Payment'
end
