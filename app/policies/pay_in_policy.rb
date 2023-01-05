class PayInPolicy < ApplicationPolicy

  def create?
    is_allow = if record.is_a?(PayIn)
      no_pay_in_present_for_currency?(record.currency) || last_pay_in_is_unlocked_for_currency?(record.currency)
    else
      no_currency_specific_pay_in_present? || last_currency_specific_pay_in_is_unlocked?
    end
    is_allow
  end

  private

    def no_currency_specific_pay_in_present?
      Payment.currencies.each_key do |c|
        return true if no_pay_in_present_for_currency?(c)
      end

      return false
    end

    def last_currency_specific_pay_in_is_unlocked? 
      Payment.currencies.each_key do |c|
        return true if last_pay_in_is_unlocked_for_currency?(c)
      end

      return false
    end

    def no_pay_in_present_for_currency?(currency)
      user.pay_ins.send(currency).none?
    end

    def last_pay_in_is_unlocked_for_currency?(currency)
      user.pay_ins.send(currency).last.unlocked?
    end
  # end of private
end
