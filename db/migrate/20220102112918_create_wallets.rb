class CreateWallets < ActiveRecord::Migration[5.2]
  def change
    create_table :wallets do |t|
      t.float :amount, default: 0.0
      t.integer :currency, default: 0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
