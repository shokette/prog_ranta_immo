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

ActiveRecord::Schema[7.0].define(version: 2024_12_15_174115) do
  create_table "guides", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hike_histories", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.date "hiking_date"
    t.string "departure_time"
    t.string "day_type"
    t.decimal "carpooling_cost", precision: 5, scale: 2
    t.integer "member_id"
    t.integer "hike_id"
    t.string "openrunner_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hike_id"], name: "index_hike_histories_on_hike_id"
    t.index ["hiking_date", "hike_id"], name: "index_hike_histories_on_hiking_date_and_hike_id", unique: true
  end

  create_table "hike_paths", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "hike_id"
    t.text "coordinates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hikes", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.integer "number"
    t.integer "day"
    t.integer "difficulty"
    t.string "starting_point"
    t.string "trail_name"
    t.float "carpooling_cost"
    t.float "distance_km"
    t.float "elevation_gain"
    t.string "openrunner_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "elevation_loss"
    t.integer "altitude_min"
    t.integer "altitude_max"
    t.boolean "updating", default: false
    t.datetime "last_update_attempt"
  end

  create_table "members", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.float "price"
    t.string "property_type"
    t.string "location"
    t.float "surface"
    t.float "rooms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
