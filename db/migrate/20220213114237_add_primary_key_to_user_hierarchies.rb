class AddPrimaryKeyToUserHierarchies < ActiveRecord::Migration[5.2]
  def change
    add_column :user_hierarchies, :id, :primary_key
  end
end
