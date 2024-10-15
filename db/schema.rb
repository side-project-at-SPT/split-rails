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

ActiveRecord::Schema[7.1].define(version: 2024_10_15_194901) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_players", id: false, force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.bigint "player_id", null: false
    t.index ["bot_id"], name: "index_ai_players_on_bot_id"
    t.index ["player_id"], name: "index_ai_players_on_player_id"
  end

  create_table "bots", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "visitor_id", null: false
    t.string "webhook_url", null: false
    t.integer "concurrent_number", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["visitor_id"], name: "index_bots_on_visitor_id"
  end

  create_table "game_steps", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.integer "step_number", null: false
    t.integer "step_type", null: false
    t.integer "current_player_index", null: false
    t.json "pastures", default: []
    t.integer "game_phase", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "action", default: {}
    t.index ["game_id"], name: "index_game_steps_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "room_id"
    t.boolean "is_finished", default: false
    t.json "players", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_player_index", default: 0
    t.index ["room_id"], name: "index_games_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "closed_at"
    t.integer "owner_id"
  end

  create_table "visitors", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "preferences"
    t.integer "role", default: 2, null: false
  end

  create_table "visitors_rooms", force: :cascade do |t|
    t.bigint "visitor_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ready", default: false
    t.string "character", default: "none"
    t.index ["room_id"], name: "index_visitors_rooms_on_room_id"
    t.index ["visitor_id"], name: "index_visitors_rooms_on_visitor_id"
  end

  add_foreign_key "bots", "visitors"
  add_foreign_key "game_steps", "games"
  add_foreign_key "visitors_rooms", "rooms"
  add_foreign_key "visitors_rooms", "visitors"
end
