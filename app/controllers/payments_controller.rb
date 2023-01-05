class PaymentsController < ApplicationController

  def verify
    @payment = find_payment
    authorize @payment
    result = VerifyPaymentService.call(trimmed_transaction_id, @payment.id)
    if result[:status] == :success
      redirect_to users_dashboard_path
    else
      render 'payment_not_confirmed.js.erb', locals: {error: result[:error]}
    end
  end

  def history
    @payments = current_user.payments
  end

  private
    def trimmed_transaction_id
      params.dig(:payment, :transaction_id).to_s.strip
    end

    def find_payment
      Payment.find(params[:payment_id])
    end

  # end of private
end



# 19a9760879011e8bd8e50d63464e7c0d541ee8be9b70e072871b5d65a7a7fbf0
