class PayOutsController < ApplicationController
  def create
    response = ::CreatePayOutPaymentOperation.call(current_user.id)
    redirect_to users_dashboard_path and return if response[:status] == :success

    render 'pay_out_create_error.js'
  end
end
