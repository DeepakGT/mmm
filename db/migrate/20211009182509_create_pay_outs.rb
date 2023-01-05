class CreatePayOuts < ActiveRecord::Migration[5.2]
  def change
    create_table :pay_outs do |t|
      t.integer :currency, default: 0
      t.integer :status, default: 0
      t.references :pay_in
      t.references :user

      t.timestamps
    end

    up_only do
      execute "SELECT setval('pay_outs_id_seq', 1000)"
    end
  end
end
