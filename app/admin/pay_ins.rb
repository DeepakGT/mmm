ActiveAdmin.register PayIn do
  config.batch_actions = false
  
  actions :index, :show

  show do
    attributes_table do
      row :currency
      row :status
      row :read_warnings
      row :user
      row :pay_in_payment
      row :created_at
      row :updated_at
    end
  end
end
