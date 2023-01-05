class CreatePayIns < ActiveRecord::Migration[5.2]
  def change
    create_table :pay_ins do |t|
      t.integer :currency, default: 0
      t.integer :status, default: 0
      t.boolean :read_warnings, default: false

      t.references :user

      t.timestamps
    end

    up_only do
      execute "SELECT setval('pay_ins_id_seq', 1000)"
    end
  end
end
