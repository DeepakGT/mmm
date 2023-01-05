class CreateReferralBonus < ActiveRecord::Migration[5.2]
  def change
    create_table :referral_bonus do |t|
      t.references :pay_in, null: false, foreign_key: true
      t.integer :currency, default: 0
      t.integer :status, default: 0

      t.timestamps
    end

    up_only do
      execute "SELECT setval('referral_bonus_id_seq', 1000)"
    end
  end
end
