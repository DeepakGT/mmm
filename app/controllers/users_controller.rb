class UsersController < ApplicationController
  before_action :make_pay_in_unlocked, only: :dashboard

  def index
    @users = children_or_descendants
  end

  def dashboard
    @system_info = fetch_system_info
    @user = get_user
    @user_info = fetch_user_info(@user) if !is_all_selected?
    assign_pay_ins_and_payments(@user)
  end

  def wallets
    @wallets = current_user.wallets
  end

  private

    def is_all_selected?
      params[:child] == 'all'
    end

    def assign_pay_ins_and_payments(user)
      # keep the calling order same, it is important
      assign_payments(user)
      assign_pay_ins(user)
    end

    def assign_payments(user)
      payments = if is_all_selected?
        Payment.by_user_ids(user.self_and_descendants.ids)
      else
        user.payments
      end

      payments = except_inactive_referral_bonus_payments(payments)

      payments = apply_filters_on_payments(payments)
      @payments = payments.order(created_at: :desc).paginate(page: params[:current_payment_page])
    end

    # remove inactive referral-bonus payments
    def except_inactive_referral_bonus_payments(payments)
      inactive_referral_bonus_payments = payments.referral_bonus.inner_join_with_referral_bonus.where('referral_bonus.status = ?', ReferralBonus.statuses[:inactive])
      payments.where.not(id: inactive_referral_bonus_payments.ids)
    end

    # must be call after payment assignment
    def assign_pay_ins(user)
      @pay_ins = PayIn.by_payment_ids(@payments.ids).distinct.order(created_at: :desc).paginate(page: params[:current_pay_in_page])
    end

    def apply_filters_on_payments(payments)
      payments = payments.send(params[:status]) unless params[:status].in?([nil, 'all'])
      payments = payments.send(params[:currency].downcase) unless params[:currency]&.downcase.in?([nil, 'all'])
      payments
    end

    def make_pay_in_unlocked
      pay_in = current_user.pay_ins.locked.first
      return if pay_in.blank?

      payment = pay_in.pay_in_payment
      will_unlock_at = payment.paid_at.in_time_zone + PayIn::LOCKING_PERIOD_IN_HOURS.hours
      if Time.zone.now >= will_unlock_at
        pay_in.unlocked!
      end
    end

    def get_user
      return current_user if is_all_selected?
      User.find_by(id: params[:child]) || current_user
    end

    def fetch_system_info
      pending_pay_ins_count = Payment.pay_in.pending.count
      pending_pay_ins_amount = helpers.number_with_precision(Payment.pay_in.pending.sum(:amount), precision: 2)
      pending_pay_outs_count = Payment.pay_out.pending.count
      pending_pay_outs_amount = helpers.number_with_precision(Payment.pay_out.pending.sum(:amount), precision: 2)
      root_created_at = User.root.order(:created_at).first&.created_at&.in_time_zone || Time.zone.now
      system_running_since = helpers.distance_of_time_in_words(Time.zone.now, root_created_at, include_seconds: true)
      { total_member: User.count,
        pending_pay_ins_count: pending_pay_ins_count,
        pending_pay_ins_amount: pending_pay_ins_amount,
        pending_pay_outs_count: pending_pay_outs_count,
        pending_pay_outs_amount: pending_pay_outs_amount,
        system_running_since: system_running_since}
    end

    def fetch_user_info(user)
      maximum_paid_in_usdt_amount = helpers.number_with_precision(user.maximum_paid_in_amount('usdt'), precision: 2)
      maximum_paid_in_trx_amount = helpers.number_with_precision(user.maximum_paid_in_amount('trx'), precision: 2)
      total_earned_referral_bonus_amount = helpers.number_with_precision(user.payments.referral_bonus.sum(:amount), precision: 2)
      unpaid_referral_bonus_amount = helpers.number_with_precision(user.payments.referral_bonus.pending.sum(:amount), precision: 2)
      { maximum_paid_in_usdt_amount: maximum_paid_in_usdt_amount,
        maximum_paid_in_trx_amount: maximum_paid_in_trx_amount,
        team_count: user.self_and_descendant_ids.count,
        children_count: user.children.count,
        total_pay_ins_count: user.pay_ins.count,
        pending_pay_outs: user.pay_outs.open.count,
        total_earned_referral_bonus_amount: total_earned_referral_bonus_amount,
        unpaid_referral_bonus_amount: unpaid_referral_bonus_amount,
        paid_usdt_pay_ins: user.pay_ins.usdt.paid.sum{|pay_in| pay_in.pay_in_payment.amount},
        paid_trx_pay_ins: user.pay_ins.trx.paid.sum{|pay_in| pay_in.pay_in_payment.amount},
        paid_usdt_pay_outs: user.pay_outs.usdt.complete.sum{|pay_out| pay_out.payment.amount},
        paid_trx_pay_outs: user.pay_outs.trx.complete.sum{|pay_out| pay_out.payment.amount}}
    end

    def children_or_descendants
      case params[:filtered_with]
      when 'referrals'
        current_user.children
      when 'participants'
        current_user.descendants
      else
        User.none
      end
    end
  # end of private
end
