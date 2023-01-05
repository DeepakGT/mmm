ActiveAdmin.register PayOut do
  config.batch_actions = false
  
  actions :index, :show

  remove_filter :pay_in

  show do
    attributes_table do
      row :currency
      row :status
      row :pay_in
      row :user
      row :payment
      row :created_at
      row :updated_at
    end
  end
end