class PaymentPolicy < ApplicationPolicy

  def verify?
    CanVerifyPaymentService.call(user, record.id)
  end

end
