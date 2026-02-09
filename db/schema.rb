# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_06_120000) do
  create_table "class_types", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_class_types_on_active"
    t.index ["name"], name: "index_class_types_on_name", unique: true
  end

  create_table "membership_package_class_types", force: :cascade do |t|
    t.integer "class_type_id", null: false
    t.datetime "created_at", null: false
    t.integer "membership_package_id", null: false
    t.datetime "updated_at", null: false
    t.index ["class_type_id"], name: "index_membership_package_class_types_on_class_type_id"
    t.index ["membership_package_id", "class_type_id"], name: "index_package_class_types_uniqueness", unique: true
    t.index ["membership_package_id"], name: "index_membership_package_class_types_on_membership_package_id"
  end

  create_table "membership_packages", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.decimal "price_modifier", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_membership_packages_on_active"
  end

  create_table "membership_plans", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "duration_months", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_membership_plans_on_active"
  end

  create_table "memberships", force: :cascade do |t|
    t.decimal "amount_paid", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.integer "membership_package_id", null: false
    t.integer "membership_plan_id", null: false
    t.date "start_date", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["end_date"], name: "index_memberships_on_end_date"
    t.index ["membership_package_id"], name: "index_memberships_on_membership_package_id"
    t.index ["membership_plan_id"], name: "index_memberships_on_membership_plan_id"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id", "status"], name: "index_memberships_on_user_id_and_status"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "password_digest", null: false
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["approved_at"], name: "index_users_on_approved_at"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "membership_package_class_types", "class_types"
  add_foreign_key "membership_package_class_types", "membership_packages"
  add_foreign_key "memberships", "membership_packages"
  add_foreign_key "memberships", "membership_plans"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
end
