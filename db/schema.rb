# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_13_114237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "pay_ins", force: :cascade do |t|
    t.integer "currency", default: 0
    t.integer "status", default: 0
    t.boolean "read_warnings", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pay_ins_on_user_id"
  end

  create_table "pay_outs", force: :cascade do |t|
    t.integer "currency", default: 0
    t.integer "status", default: 0
    t.bigint "pay_in_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pay_in_id"], name: "index_pay_outs_on_pay_in_id"
    t.index ["user_id"], name: "index_pay_outs_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.float "amount"
    t.integer "currency", default: 0
    t.integer "payment_type"
    t.integer "status"
    t.text "receiver_wallet_number"
    t.string "wallet_holder_name"
    t.text "transaction_id"
    t.integer "activity_id"
    t.bigint "user_id"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_payments_on_activity_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "referral_bonus", force: :cascade do |t|
    t.bigint "pay_in_id", null: false
    t.integer "currency", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pay_in_id"], name: "index_referral_bonus_on_pay_in_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "email"
    t.string "subject"
    t.text "message"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
  end

  create_table "user_hierarchies", force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "user_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "user_desc_idx"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "role", default: 0
    t.integer "status", default: 0
    t.integer "parent_id"
    t.string "mobile"
    t.string "country"
    t.string "time_zone", default: "UTC", null: false
    t.string "wallet_number"
    t.boolean "read_agreement", default: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.float "amount", default: 0.0
    t.integer "currency", default: 0
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "referral_bonus", "pay_ins"
  add_foreign_key "wallets", "users"
end
