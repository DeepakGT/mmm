class CreateSupportTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :support_tickets do |t|
      t.references :user, null: true
      t.string :email
      t.string :subject
      t.text :message
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
