class PayIn < ApplicationRecord
  include HasCurrency

  self.per_page = 3
  
  GROWTH_RATE = 0.8 # in percent
  LOCKING_PERIOD_IN_HOURS = 360
  
  enum status: {'open': 0 ,'locked': 1, 'unlocked': 2, 'settled': 3}
  
  validates :read_warnings, presence: true
  validates :read_warnings, acceptance: true
  
  belongs_to :user
  has_one :pay_out
  has_one :referral_bonus
  has_one :assurance_payment, -> { where(payment_type: Payment.payment_types[:assurance]) }, foreign_key: :activity_id, class_name: 'Payment'
  has_one :pay_in_payment, -> { where(payment_type: Payment.payment_types[:pay_in]) }, foreign_key: :activity_id, class_name: 'Payment'

  has_many :payments, 
  -> { where(payment_type: [Payment.payment_types[:pay_in], Payment.payment_types[:assurance]]) }, foreign_key: :activity_id

  scope :by_payment_ids, ->(ids) { joins(:payments).where('payments.id': ids) }
  scope :with_no_pay_outs, -> { includes(:pay_out).where("pay_outs.pay_in": nil) }
  scope :paid, -> { where.not(status: [PayIn.statuses[:open]]) }

  def amount
    self.payments.pay_in.first.amount
  end

  def self.active_pay_ins
    self.where(status: [statuses[:locked], statuses[:unlocked]])
  end

  def growth_start_time
    self.pay_in_payment.paid_at.to_datetime
  end

  def growth_end_time
    (self.pay_in_payment.paid_at + PayIn::LOCKING_PERIOD_IN_HOURS.hours).to_datetime
  end

  def total_growth
    one_day_interest = Utilities::Calculator.calculate_interest(amount, PayIn::GROWTH_RATE)
    total_days = LOCKING_PERIOD_IN_HOURS/24

    total_days * one_day_interest
  end

  def current_growth
    one_day_interest = Utilities::Calculator.calculate_interest(amount, PayIn::GROWTH_RATE)
    days_upto = ((DateTime.now.in_time_zone - self.pay_in_payment.paid_at.in_time_zone)/1.hours/24).to_i

    days_upto * one_day_interest
  end

  def matuarity_amount
    total_growth + self.pay_in_payment.amount
  end

  def current_amount
    current_growth + self.pay_in_payment.amount
  end

end
