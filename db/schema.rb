# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101011012512) do

  create_table "attachments", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "user_id"
  end

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "comments", ["task_id"], :name => "index_comments_on_task_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "customers", :force => true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "projects", :force => true do |t|
    t.text     "name"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.decimal  "estimate",      :precision => 10, :scale => 2
    t.string   "state"
    t.integer  "weight",                                       :default => 0
    t.string   "estimate_unit"
    t.float    "rate"
    t.boolean  "fixed_price"
    t.date     "deadline"
    t.string   "kind",                                         :default => "development"
  end

  add_index "projects", ["customer_id"], :name => "index_projects_on_customer_id"
  add_index "projects", ["user_id"], :name => "index_projects_on_user_id"

  create_table "stakeholders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.text     "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.text     "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                         :default => "not_started"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "assigned_to_id"
    t.integer  "weight",                                        :default => 0
    t.decimal  "estimate",       :precision => 10, :scale => 2
  end

  add_index "tasks", ["assigned_to_id"], :name => "index_tasks_on_assigned_to_id"
  add_index "tasks", ["project_id"], :name => "index_tasks_on_project_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "timeslices", :force => true do |t|
    t.text     "description"
    t.integer  "task_id"
    t.datetime "started"
    t.datetime "finished"
    t.boolean  "chargeable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "ar"
    t.integer  "ap"
  end

  add_index "timeslices", ["task_id"], :name => "index_timeslices_on_task_id"
  add_index "timeslices", ["user_id"], :name => "index_timeslices_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.boolean  "is_staff",            :default => false
    t.integer  "minute_step",         :default => 15
    t.integer  "login_count",         :default => 0,     :null => false
    t.integer  "failed_login_count",  :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "single_access_token", :default => "0",   :null => false
    t.string   "perishable_token",    :default => "0",   :null => false
    t.text     "ignore_mail"
  end

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "changes"
    t.integer  "number"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end
