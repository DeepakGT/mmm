class PayOutPolicy < ApplicationPolicy

  def create?
    any_unlocked_pay_in? && 
    (any_locked_pay_in_with_same_currency? || is_minimum_two_unlocked_pay_in_with_same_currency?)
  end

  private

    def any_unlocked_pay_in?
      user.pay_ins.with_no_pay_outs.unlocked.any?
    end

    def any_locked_pay_in_with_same_currency?
      user.pay_ins.with_no_pay_outs.locked.any? &&
      (user.pay_ins.with_no_pay_outs.locked.pluck(:currency) & user.pay_ins.with_no_pay_outs.unlocked.pluck(:currency)).any?
    end

    def is_minimum_two_unlocked_pay_in_with_same_currency?
      currencies = user.pay_ins.with_no_pay_outs.unlocked.pluck(:currency)
      currencies.detect{|val| currencies.count(val) > 1}.present?
    end

  # end of private

end
