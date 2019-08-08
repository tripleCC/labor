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

ActiveRecord::Schema.define(version: 20190808063828) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_infos", force: :cascade do |t|
    t.string   "name"
    t.string   "version"
    t.datetime "created_at"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "leak_info_id"
    t.string   "user_name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["leak_info_id"], name: "index_comments_on_leak_info_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "devices", force: :cascade do |t|
    t.string   "name"
    t.string   "simple_name"
    t.datetime "created_at"
  end

  create_table "launch_infos", force: :cascade do |t|
    t.integer  "app_info_id"
    t.integer  "os_info_id"
    t.string   "will_to_did"
    t.string   "start_to_did"
    t.string   "load_total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "device_id"
  end

  add_index "launch_infos", ["app_info_id"], name: "index_launch_infos_on_app_info_id", using: :btree
  add_index "launch_infos", ["device_id"], name: "index_launch_infos_on_device_id", using: :btree
  add_index "launch_infos", ["os_info_id"], name: "index_launch_infos_on_os_info_id", using: :btree

  create_table "leak_infos", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "app_info_id"
    t.string   "name"
    t.text     "trace"
    t.boolean  "active",      default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cycles"
  end

  add_index "leak_infos", ["app_info_id"], name: "index_leak_infos_on_app_info_id", using: :btree
  add_index "leak_infos", ["user_id"], name: "index_leak_infos_on_user_id", using: :btree

  create_table "load_duration_pairs", force: :cascade do |t|
    t.integer  "launch_info_id"
    t.string   "name"
    t.string   "duration"
    t.datetime "created_at"
  end

  add_index "load_duration_pairs", ["launch_info_id"], name: "index_load_duration_pairs_on_launch_info_id", using: :btree

  create_table "main_deploys", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "repo_url"
    t.string   "ref"
    t.string   "status"
    t.string   "failure_reason"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "should_push_ding", default: true
    t.integer  "project_id"
  end

  add_index "main_deploys", ["project_id"], name: "index_main_deploys_on_project_id", using: :btree
  add_index "main_deploys", ["user_id"], name: "index_main_deploys_on_user_id", using: :btree

  create_table "merge_requests", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "pod_deploy_id"
    t.string   "mid"
    t.string   "miid"
    t.string   "title"
    t.string   "sha"
    t.string   "state",                        default: "opened"
    t.string   "merge_status",                 default: "unchecked"
    t.string   "target_branch"
    t.string   "source_branch"
    t.string   "web_url"
    t.boolean  "merge_when_pipeline_succeeds", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_requests", ["pod_deploy_id"], name: "index_merge_requests_on_pod_deploy_id", using: :btree
  add_index "merge_requests", ["project_id"], name: "index_merge_requests_on_project_id", using: :btree

  create_table "operations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "deploy_name"
    t.integer  "deploy_type", default: 0
  end

  add_index "operations", ["user_id"], name: "index_operations_on_user_id", using: :btree

  create_table "os_infos", force: :cascade do |t|
    t.string   "name"
    t.string   "version"
    t.datetime "created_at"
  end

  create_table "pipelines", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "pod_deploy_id"
    t.string   "pid"
    t.string   "sha"
    t.string   "ref"
    t.string   "status"
    t.string   "web_url"
    t.boolean  "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pipelines", ["pod_deploy_id"], name: "index_pipelines_on_pod_deploy_id", using: :btree
  add_index "pipelines", ["project_id"], name: "index_pipelines_on_project_id", using: :btree

  create_table "pod_deploys", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "main_deploy_id"
    t.string   "name"
    t.string   "repo_url"
    t.string   "ref",                       default: "master"
    t.string   "version",                                      null: false
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
    t.string   "created_tags",              default: [],                    array: true
    t.integer  "project_id"
  end

  add_index "pod_deploys", ["main_deploy_id"], name: "index_pod_deploys_on_main_deploy_id", using: :btree
  add_index "pod_deploys", ["project_id"], name: "index_pod_deploys_on_project_id", using: :btree
  add_index "pod_deploys", ["user_id"], name: "index_pod_deploys_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.string   "ssh_url_to_repo"
    t.string   "http_url_to_repo"
    t.string   "web_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specifications", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "name"
    t.string   "version"
    t.string   "summary"
    t.json     "authors",                        default: []
    t.json     "source",                         default: {}
    t.integer  "spec_type",                      default: 2
    t.string   "spec_external_dependency_names", default: [],    array: true
    t.text     "spec_content"
    t.boolean  "third_party",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner",                          default: "未知"
    t.string   "team",                           default: "未知"
  end

  add_index "specifications", ["project_id"], name: "index_specifications_on_project_id", using: :btree
  add_index "specifications", ["user_id"], name: "index_specifications_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "pod_deploy_id"
    t.string   "name"
    t.string   "target"
    t.string   "message"
    t.string   "sha"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["pod_deploy_id"], name: "index_tags_on_pod_deploy_id", using: :btree
  add_index "tags", ["project_id"], name: "index_tags_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "sub"
    t.string   "nickname"
    t.string   "email"
    t.string   "phone_number"
    t.string   "picture"
    t.boolean  "superman",         default: false
    t.text     "unofficial_names", default: [],    array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
