class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.float :amount
      t.integer :currency, default: 0
      t.integer :payment_type
      t.integer :status
      t.text :receiver_wallet_number
      t.string :wallet_holder_name
      t.text :transaction_id
      t.integer :activity_id, index: true
      t.references :user
      t.datetime :paid_at

      t.timestamps
    end

    up_only do
      execute "SELECT setval('payments_id_seq', 1000)"
    end
  end
end
