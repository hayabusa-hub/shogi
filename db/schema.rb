# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_21_021306) do

  create_table "games", force: :cascade do |t|
    t.integer "first_user_id"
    t.integer "second_user_id"
    t.text "board"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "own_piece"
    t.text "turn_board"
    t.integer "turn"
    t.integer "first_user_board"
    t.integer "second_user_board"
    t.integer "first_king_pos", default: 74
    t.integer "second_king_pos", default: 4
    t.integer "winner", default: 0
  end

  create_table "matches", force: :cascade do |t|
    t.integer "user_id"
    t.integer "opponent_id", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "game_id"
    t.index ["user_id"], name: "index_matches_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
