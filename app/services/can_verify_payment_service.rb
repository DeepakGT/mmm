class CanVerifyPaymentService
  class << self
    def call(user, payment_id)
      is_allowed = validate_prerequisite_payments(user, payment_id)
      is_allowed
    end

    private

      def validate_prerequisite_payments(user, payment_id)
        payment = find_payment(payment_id)

        if payment.assurance? # && is_all_prev_pay_ins_locked?(user, payment)
          return true 
        elsif payment.pay_in? && payment.pay_in.assurance_payment.complete?
          return true
        elsif payment.pay_out?
          return true
        elsif payment.referral_bonus?
          return false
        end

        return false
      end

      def find_payment(payment_id)
        Payment.find(payment_id)
      end

      # def is_all_prev_pay_ins_locked?(user, payment)
      #   user.pay_ins.where('created_at < ? AND currency = ?', 
      #     payment.pay_in.created_at, Payment.currencies[payment.currency]
      #   ).all?{ |pu| pu.open? || pu.locked? }
      # end

    # end of private
  end
end
