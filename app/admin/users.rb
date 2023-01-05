ActiveAdmin.register User do

  actions :index, :show

  index do
    column :id
    column :name
    column :email
    column :role
    column :status
    column :parent
    column :mobile
    column :country
    column :timezone
    column :wallet_number
    column :read_agreement
    column :created_at
    actions
  end

  show do
    attributes_table do
      exclude_columns = ['id']
      columns = User.column_names
      childrens_position = columns.find_index('parent_id')+1
      columns = columns - exclude_columns
      columns = columns.insert(childrens_position, 'children')
      
      columns.each do |c_name|
        row c_name.to_sym
      end
    end
  end

  filter :parent
  filter :children
  filter :name
  filter :email
  filter :role
  filter :status
  filter :mobile
  filter :country
  filter :timezone
  filter :wallet_number
  filter :read_agreement
  filter :created_at

end
