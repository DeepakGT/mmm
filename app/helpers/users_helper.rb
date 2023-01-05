module UsersHelper

  def get_payment_modal_id(payment)
    if payment.assurance?
      "assurancePaymentModal-#{payment.id}"
    elsif payment.pay_in?
      "payInPaymentModal-#{payment.id}"
    end
  end

  def payment_status(assurance_payment)
    assurance_payment.complete? ? 'PAID' : 'Waiting...'
  end

  def pending_amount(pay_in)
    if !pay_in.assurance_payment.complete?
      pay_in.assurance_payment.amount + pay_in.pay_in_payment.amount
    elsif !pay_in.pay_in_payment.complete?
      pay_in.pay_in_payment.amount
    else
      0
    end
  end

  def pay_in_card_status(pay_in)
    return 'Waiting for payment' if pay_in.open?
    
    pay_in.status
  end

  def pay_in_card_status_classes(pay_in)
    if pay_in.locked?
      'text-warning'
    elsif  pay_in.unlocked?
      'text-info'
    elsif pay_in.settled?
      'text-success'
    else
      ''
    end
  end

  def pay_in_card_border_classes(pay_in)
    if pay_in.locked?
      'border-warning'
    elsif  pay_in.unlocked?
      'border-info'
    elsif pay_in.settled?
      'border-success'
    else
      ''
    end
  end

  def uniq_number(obj)
    if obj.is_a?(PayIn)
      "P#{obj.id}"
    else
      if obj.assurance?
        "A#{obj.pay_in.id}"
      elsif obj.pay_in?
        "P#{obj.pay_in.id}"
      elsif obj.pay_out?
        "G#{obj.pay_out.id}"
      elsif obj.referral_bonus?
        "RB#{obj.referral_bonus.id}"
      end
    end
  end

  def payment_remaining_time(payment)
    return '' if payment.pay_in? && payment.pay_in.assurance_payment.pending?
    is_time_over = is_time_over?(payment)
    from_time = from_time_to_calculate_remaining_time(payment)
    to_time = payment.created_at + to_time_to_calculate_remaining_time(payment)
    
    if is_time_over
      make_user_inactive!
      return "Time Over #{fa_icon 'hourglass-end'}"
    end

    remained_time = distance_of_time_in_words(from_time, to_time)
    "#{remained_time} remained #{fa_icon 'hourglass-half'}"
  end

  def is_time_over?(payment)
    from_time = from_time_to_calculate_remaining_time(payment)
    return true if from_time.blank?
    to_time = payment.created_at + to_time_to_calculate_remaining_time(payment)
    return true if from_time > to_time

    false
  end

  def from_time_to_calculate_remaining_time(payment)
    return Time.zone.now if payment.assurance? || payment.pay_out? || payment.referral_bonus?
    return payment.pay_in.assurance_payment.paid_at if payment.pay_in?
  end

  def to_time_to_calculate_remaining_time(payment)
    return 480.hours if payment.assurance?
    return 1000.hours if payment.pay_in? || payment.pay_out? || payment.referral_bonus?
  end

  def get_error_for(obj, attr)
    obj.errors[attr].first
  end

  def pay_out_modal_data
    unlocked_pay_in = current_user.first_unlocked_pay_in_with_no_pay_out
    
    principal_amount = unlocked_pay_in.amount
    currency = unlocked_pay_in.currency
    growth_amount = unlocked_pay_in.total_growth
    welcome_bonus = current_user.get_welcome_bonus(principal_amount)
    total_referral_bonus_amount = current_user.total_referral_bonus_amount
    wallet_balance = current_user.wallet_balance(currency).to_f
    total_amount = ::Utilities::Calculator.total_payout_amount(principal_amount, growth_amount, wallet_balance, welcome_bonus, total_referral_bonus_amount)
    not_releasable_amount = total_amount%10
    releasable_amount = total_amount - not_releasable_amount
    {
      principal_amount: principal_amount,
      growth_amount: growth_amount,
      welcome_bonus: welcome_bonus,
      total_amount: total_amount,
      total_referral_bonus_amount: total_referral_bonus_amount,
      wallet_balance: wallet_balance.round(2),
      releasable_amount: releasable_amount,
      not_releasable_amount: not_releasable_amount
    }
  end

  def payment_row_classes(payment)
    if payment.complete?
      'greenStatus'
    elsif payment.pay_out?
      'yellowStatus'
    elsif payment.referral_bonus?
      'redStatus'
    else
      'blueStatus'
    end
  end

  def make_user_inactive!
    current_user.inactive!
  end

  def children_select_lable(user)
    select_label = "#{user.name.titleize}"
    select_label = if current_user.id == user.id
      "#{select_label} [You]"
    else
      "#{select_label}(#{user.role})"
    end
    select_label
  end

  def selectable_currencies
    currencies = current_user.pay_ins.where(status: PayIn.statuses.values_at('open', 'locked')).map(&:currency)
    Payment.currencies.keys.reject{|key| key.in?(currencies)}
  end

end
