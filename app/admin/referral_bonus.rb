ActiveAdmin.register ReferralBonus do
  config.batch_actions = false
  
  actions :index, :show

  remove_filter :pay_in

  show do
    attributes_table do
      row :pay_in
      row :currency
      row :status
      row :payments
      row :created_at
      row :updated_at
    end
  end
end