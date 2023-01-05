module HasCurrency
  extend ActiveSupport::Concern
  included do
    enum currency: {usdt: 0, trx: 1}

    validates :currency, presence: true
    validate :validate_currency
  end

  private

    def validate_currency
      if self.is_a?(Payment)
        validate_payment
      elsif self.class.name.in?(['PayIn', 'PayOut', 'ReferralBonus'])
        validate_activity
      else
        true
      end
    end

    def validate_payment
      if self.assurance?
        return if self.pay_in.currency == self.currency
      elsif self.pay_in?
        return if self.pay_in.assurance_payment.currency == self.currency
        return if self.pay_in.currency == self.currency
      elsif self.pay_out?
        return if self.pay_out.currency == self.currency
      elsif self.referral_bonus?
        return if self.referral_bonus.currency == self.currency
      end

      errors.add(:currency, 'invalid currency')
    end

    def validate_activity
      if self.class.name == 'PayOut'
        return true if self.payment.blank?

        if self.payment.currency != self.currency
          errors.add(:currency, 'invalid currency')
        end
      else
        return true if self.payments.blank?

        if self.payments.pluck(:currency).uniq.length != 1 ||
          !self.payments.pluck(:currency).include?(self.currency)
          errors.add(:currency, 'invalid currency')
        end
      end
    end

  # end of private
end
