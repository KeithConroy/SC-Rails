# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150807025821) do

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.date     "date"
    t.time     "time"
  end

  add_index "events", ["organization_id"], name: "index_events_on_organization_id"

  create_table "events_rooms", id: false, force: :cascade do |t|
    t.integer "room_id",  null: false
    t.integer "event_id", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "title"
    t.integer  "quantity"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "disposable"
  end

  add_index "items", ["organization_id"], name: "index_items_on_organization_id"

  create_table "organizations", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string   "title"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "number"
    t.string   "building"
    t.text     "description"
  end

  add_index "rooms", ["organization_id"], name: "index_rooms_on_organization_id"

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "users", ["organization_id"], name: "index_users_on_organization_id"

end
