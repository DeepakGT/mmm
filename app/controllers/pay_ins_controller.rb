class PayInsController < ApplicationController

  before_action :validate_amount, only: :create

  def create
    pay_in = PayIn.new(status: PayIn.statuses[:open], user_id: current_user.id, currency: params[:currency].downcase, read_warnings: params[:read_warnings])
    authorize pay_in

    if pay_in.save
      response = ::CreatePayInPaymentsOperation.call(current_user.id, pay_in.id, amount, params[:currency].downcase)
      if response[:status] == :success
        CreateReferralBonusesOperation.call(current_user.id, pay_in.pay_in_payment.amount, pay_in.id)
        redirect_to users_dashboard_path and return
      end
    end

    pay_in.destroy if pay_in.persisted?
    render 'pay_in_create_error.js.erb'
  end

  def show_growth
    @active_pay_ins = current_user.pay_ins.active_pay_ins.order(:created_at)
  end

  private

    def amount
      params[:amount].to_i
    end

    def validate_amount
      minimum_valid_amount = current_user.payments.new.minimum_valid_amount
      if !(amount%10).zero? || amount < minimum_valid_amount || amount > Payment.maximum_valid_amount(params[:currency].downcase)
        render 'pay_in_create_error.js.erb' and return
      end
    end
  # end of private

end
