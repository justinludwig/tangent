# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "event_coordinators", :force => true do |t|
    t.integer "event_id"
    t.integer "coordinator_id"
  end

  create_table "events", :force => true do |t|
    t.string   "name",        :limit => 50
    t.string   "description", :limit => 50
    t.text     "details"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string   "email",            :limit => 50
    t.string   "display_name",     :limit => 50
    t.string   "crypted_password", :limit => 50
    t.string   "salt",             :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",            :limit => 20, :default => "passive"
    t.datetime "deleted_at"
  end

end
