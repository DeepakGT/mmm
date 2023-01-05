class Admin::ApplicationPolicy < ActiveAdmin::AuthorizationAdapter

  def authorized?(action, subject = nil)
    # only incomplete assurance and pay_in payments can be update
    if subject.is_a?(Payment) && !subject.pay_out?
      if action.in?([:edit, :update])
        return false
      end
    end
    true
  end

end
