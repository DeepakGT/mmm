module ApplicationHelper

  def referal_id(user)
    "#{User::REFERRAL_ID_PREFIX}#{user.id}"
  end

end
