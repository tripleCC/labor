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

ActiveRecord::Schema.define(version: 20181105025925) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "main_deploys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "repo_url"
    t.string   "ref"
    t.string   "project_id"
    t.string   "status"
    t.string   "failure_reason"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "main_deploys", ["user_id"], name: "index_main_deploys_on_user_id", using: :btree

  create_table "operations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "pod_deploy_id"
    t.integer  "main_deploy_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operations", ["main_deploy_id"], name: "index_operations_on_main_deploy_id", using: :btree
  add_index "operations", ["pod_deploy_id"], name: "index_operations_on_pod_deploy_id", using: :btree
  add_index "operations", ["user_id"], name: "index_operations_on_user_id", using: :btree

  create_table "pod_deploys", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "main_deploy_id"
    t.string   "name"
    t.string   "project_id"
    t.string   "repo_url"
    t.string   "ref",                       default: "master"
    t.string   "version"
    t.text     "external_dependency_names", default: [],                    array: true
    t.string   "mr_pipeline_id"
    t.string   "cd_pipeline_id"
    t.string   "owner"
    t.string   "owner_mobile"
    t.string   "owner_ding_token"
    t.text     "merge_request_iids",        default: [],                    array: true
    t.string   "status"
    t.string   "failure_reason"
    t.boolean  "reviewed",                  default: false,    null: false
    t.boolean  "manual",                    default: false,    null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pod_deploys", ["main_deploy_id"], name: "index_pod_deploys_on_main_deploy_id", using: :btree
  add_index "pod_deploys", ["user_id"], name: "index_pod_deploys_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "sub"
    t.string   "nickname"
    t.string   "email"
    t.string   "phone_number"
    t.string   "picture"
    t.boolean  "superman"
    t.text     "unofficial_names", default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
