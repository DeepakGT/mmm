class PayOut < ApplicationRecord
  include HasCurrency

  WELCOME_BONUS = 5.0 # in percent

  belongs_to :pay_in
  belongs_to :user
  
  enum status: {'open': 0, 'complete': 1}

  has_one :payment, -> { where(payment_type: Payment.payment_types[:pay_out]) }, foreign_key: :activity_id

end
