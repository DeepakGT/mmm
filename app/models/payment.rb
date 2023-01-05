class Payment < ApplicationRecord
  include HasCurrency

  WALLET_NUMBERS = ['TF31o9r7yb8iVtmBBw4QW9WatYA2js4oKo']
  ASSURANCE_AMOUNT_WALLET_NUMBER = 'TF31o9r7yb8iVtmBBw4QW9WatYA2js4oKo'

  self.per_page = 10
  MAXIMUM_VALID_USDT_AMOUNT = 1000
  MAXIMUM_VALID_TRX_AMOUNT = 10000
  MINIMUM_VALID_USDT_AMOUNT = 10
  MINIMUM_VALID_TRX_AMOUNT = 100

  belongs_to :user

  before_validation :assign_paid_at, if: :complete?

  validates :transaction_id, :paid_at, presence: true, if: :complete?
  validates :amount, presence: true

  validate :validate_amount 

  validate :validate_transaction_id_along_with_status

  enum payment_type: {assurance: 1, pay_in: 2, pay_out: 3, referral_bonus: 4}
  enum status: {pending: 0, complete: 1}

  scope :by_user_ids, ->(user_ids) { where(user_id: user_ids) }
  scope :inner_join_with_referral_bonus, -> { joins("INNER JOIN referral_bonus on payments.activity_id = referral_bonus.id") }

  def self.maximum_valid_amount(currency)
    if currency.downcase == 'usdt'
      Payment::MAXIMUM_VALID_USDT_AMOUNT
    elsif currency.downcase == 'trx'
      Payment::MAXIMUM_VALID_TRX_AMOUNT
    else
      0
    end
  end

  def pay_in
    return nil unless self.assurance? || self.pay_in?
    PayIn.find_by(id: self.activity_id)
  end

  def pay_out
    return nil unless self.pay_out?
    PayOut.find_by(id: self.activity_id)
  end

  def activity
    self.payment_type.camelcase.constantize.find(self.activity_id)
  end

  def self.by_active_referral_bonus
    ReferralBonus.find_by(id: self.activity_id)
    self.joins(:referral_bonus)
  end

  def referral_bonus
    return nil unless self.referral_bonus?
    ReferralBonus.find_by(id: self.activity_id)
  end

  def referral_bonus_by
    referral_bonus.pay_in.user
  end

  def assign_paid_at
    self.paid_at = DateTime.now.in_time_zone
  end

  def minimum_valid_amount
    min_amount = if self.usdt?
      MINIMUM_VALID_USDT_AMOUNT
    elsif self.trx?
      MINIMUM_VALID_TRX_AMOUNT
    else
      0
    end
    max_amount = self.user.maximum_paid_in_amount(self.currency)
    max_amount.zero? ? min_amount : max_amount
  end

  private
    def validate_amount
      return unless self.pay_in?

      max_valid_amt = Payment.maximum_valid_amount(self.currency)
      if self.amount < minimum_valid_amount
        self.errors.add(:amount, "should not be less than #{minimum_valid_amount}")
      end
      if self.amount > max_valid_amt
        self.errors.add(:amount, "should not be greater than #{max_valid_amt}")
      end
    end

    def validate_transaction_id_along_with_status
      if self.transaction_id.present? && self.pending?
        self.errors.add(:base, 'transaction_id can not be present for pending payment')
      end
      if self.transaction_id.blank? && self.complete?
        self.errors.add(:base, 'transaction_id must be present for complete payment')
      end
    end

  # end of private

end
