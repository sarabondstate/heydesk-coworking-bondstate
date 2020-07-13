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

ActiveRecord::Schema.define(version: 20200529093711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "text"
    t.integer  "user_id"
    t.integer  "task_id"
    t.index ["created_at"], name: "index_comments_on_created_at", using: :btree
    t.index ["task_id"], name: "index_comments_on_task_id", using: :btree
    t.index ["updated_at"], name: "index_comments_on_updated_at", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "comments_tags", id: false, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "tag_id",     null: false
    t.index ["comment_id", "tag_id"], name: "index_comments_tags_on_comment_id_and_tag_id", using: :btree
  end

  create_table "comments_users", id: false, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "user_id",    null: false
    t.index ["comment_id", "user_id"], name: "index_comments_users_on_comment_id_and_user_id", using: :btree
  end

  create_table "common_horses", force: :cascade do |t|
    t.string   "name",                                null: false
    t.string   "registration_number",                 null: false
    t.date     "birthday"
    t.string   "nationality"
    t.string   "string"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "breeder"
    t.string   "owner"
    t.string   "chip_number"
    t.string   "mom"
    t.string   "dad"
    t.integer  "winning_percentage"
    t.integer  "number_of_starts"
    t.float    "earnings_danish"
    t.float    "earnings_norwegian"
    t.float    "earnings_swedish"
    t.string   "gender"
    t.integer  "sportsinfo_id"
    t.integer  "father_id"
    t.integer  "mother_id"
    t.integer  "sportsinfo_trainer_id"
    t.integer  "first_prices",          default: 0
    t.integer  "second_prices",         default: 0
    t.integer  "third_prices",          default: 0
    t.float    "record_time",           default: 0.0
    t.float    "record_time_auto",      default: 0.0
    t.integer  "price",                 default: 0
    t.index ["sportsinfo_id"], name: "index_common_horses_on_sportsinfo_id", using: :btree
  end

  create_table "custom_field_types", force: :cascade do |t|
    t.string   "name"
    t.integer  "number_of_inputs", default: 1
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.string   "value_one"
    t.string   "value_two"
    t.integer  "task_id"
    t.integer  "custom_field_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["created_at"], name: "index_custom_field_values_on_created_at", using: :btree
    t.index ["custom_field_id"], name: "index_custom_field_values_on_custom_field_id", using: :btree
    t.index ["task_id"], name: "index_custom_field_values_on_task_id", using: :btree
    t.index ["updated_at"], name: "index_custom_field_values_on_updated_at", using: :btree
    t.index ["value_one"], name: "index_custom_field_values_on_value_one", using: :btree
    t.index ["value_two"], name: "index_custom_field_values_on_value_two", using: :btree
  end

  create_table "custom_fields", force: :cascade do |t|
    t.string   "name"
    t.integer  "stable_id"
    t.integer  "custom_field_type_id"
    t.integer  "tag_type_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["created_at"], name: "index_custom_fields_on_created_at", using: :btree
    t.index ["custom_field_type_id"], name: "index_custom_fields_on_custom_field_type_id", using: :btree
    t.index ["name"], name: "index_custom_fields_on_name", using: :btree
    t.index ["stable_id"], name: "index_custom_fields_on_stable_id", using: :btree
    t.index ["tag_type_id"], name: "index_custom_fields_on_tag_type_id", using: :btree
    t.index ["updated_at"], name: "index_custom_fields_on_updated_at", using: :btree
  end

  create_table "custom_fields_tags", id: false, force: :cascade do |t|
    t.integer "tag_id",          null: false
    t.integer "custom_field_id", null: false
    t.index ["custom_field_id", "tag_id"], name: "index_custom_fields_tags_on_custom_field_id_and_tag_id", using: :btree
  end

  create_table "developer_messages", force: :cascade do |t|
    t.string   "message"
    t.string   "origin"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "job",        default: ""
    t.index ["job"], name: "index_developer_messages_on_job", using: :btree
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "stable_id"
    t.index ["created_at"], name: "index_feedbacks_on_created_at", using: :btree
    t.index ["notifiable_type", "notifiable_id"], name: "index_feedbacks_on_notifiable_type_and_notifiable_id", using: :btree
    t.index ["stable_id"], name: "index_feedbacks_on_stable_id", using: :btree
    t.index ["updated_at"], name: "index_feedbacks_on_updated_at", using: :btree
  end

  create_table "find_trainers", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "for_trainers", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "horse_flags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "horse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["horse_id"], name: "index_horse_flags_on_horse_id", using: :btree
    t.index ["user_id"], name: "index_horse_flags_on_user_id", using: :btree
  end

  create_table "horse_ownerships", force: :cascade do |t|
    t.integer  "horse_id"
    t.integer  "owner_id"
    t.float    "percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "horse_setups", force: :cascade do |t|
    t.integer  "setup_topic_id"
    t.integer  "horse_id"
    t.text     "description"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["horse_id"], name: "index_horse_setups_on_horse_id", using: :btree
    t.index ["setup_topic_id"], name: "index_horse_setups_on_setup_topic_id", using: :btree
  end

  create_table "horse_user_stable_roles", force: :cascade do |t|
    t.integer  "user_stable_role_id"
    t.integer  "horse_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "horses", force: :cascade do |t|
    t.integer  "stable_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "deleted_at"
    t.integer  "common_horse_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "active",              default: true
    t.integer  "sorting"
    t.index ["active"], name: "index_horses_on_active", using: :btree
    t.index ["avatar_updated_at"], name: "index_horses_on_avatar_updated_at", using: :btree
    t.index ["common_horse_id"], name: "index_horses_on_common_horse_id", using: :btree
    t.index ["created_at"], name: "index_horses_on_created_at", using: :btree
    t.index ["deleted_at"], name: "index_horses_on_deleted_at", using: :btree
    t.index ["sorting"], name: "index_horses_on_sorting", using: :btree
    t.index ["stable_id"], name: "index_horses_on_stable_id", using: :btree
    t.index ["updated_at"], name: "index_horses_on_updated_at", using: :btree
  end

  create_table "horses_my_lists", id: false, force: :cascade do |t|
    t.integer "horse_id",   null: false
    t.integer "my_list_id", null: false
    t.index ["horse_id", "my_list_id"], name: "index_horses_my_lists_on_horse_id_and_my_list_id", using: :btree
  end

  create_table "horses_tags", force: :cascade do |t|
    t.integer  "horse_id"
    t.integer  "tag_id"
    t.datetime "tag_updated"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["created_at"], name: "index_horses_tags_on_created_at", using: :btree
    t.index ["horse_id"], name: "index_horses_tags_on_horse_id", using: :btree
    t.index ["tag_id"], name: "index_horses_tags_on_tag_id", using: :btree
    t.index ["tag_updated"], name: "index_horses_tags_on_tag_updated", using: :btree
    t.index ["updated_at"], name: "index_horses_tags_on_updated_at", using: :btree
  end

  create_table "horses_templates", id: false, force: :cascade do |t|
    t.integer "horse_id",    null: false
    t.integer "template_id", null: false
    t.index ["template_id", "horse_id"], name: "index_horses_templates_on_template_id_and_horse_id", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.string   "name"
    t.string   "picture"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_images_on_user_id", using: :btree
  end

  create_table "import_trainers", force: :cascade do |t|
    t.integer "sportsinfo_id"
    t.string  "name"
  end

  create_table "movies", force: :cascade do |t|
    t.string   "video"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "my_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "stable_id"
    t.string   "icon"
    t.index ["created_at"], name: "index_my_lists_on_created_at", using: :btree
    t.index ["stable_id"], name: "index_my_lists_on_stable_id", using: :btree
    t.index ["updated_at"], name: "index_my_lists_on_updated_at", using: :btree
    t.index ["user_id", "stable_id"], name: "index_my_lists_on_user_id_and_stable_id", using: :btree
    t.index ["user_id"], name: "index_my_lists_on_user_id", using: :btree
  end

  create_table "my_lists_tags", id: false, force: :cascade do |t|
    t.integer "my_list_id", null: false
    t.integer "tag_id",     null: false
    t.index ["my_list_id", "tag_id"], name: "index_my_lists_tags_on_my_list_id_and_tag_id", using: :btree
  end

  create_table "owner_requests", force: :cascade do |t|
    t.integer  "common_horse_id"
    t.integer  "stable_id"
    t.integer  "status",          default: 0
    t.integer  "user_id"
    t.integer  "trainer_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["common_horse_id"], name: "index_owner_requests_on_common_horse_id", using: :btree
    t.index ["stable_id"], name: "index_owner_requests_on_stable_id", using: :btree
  end

  create_table "owners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "owners_horses", force: :cascade do |t|
    t.string   "gmail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ownerships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "common_horse_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["common_horse_id"], name: "index_ownerships_on_common_horse_id", using: :btree
    t.index ["user_id"], name: "index_ownerships_on_user_id", using: :btree
  end

  create_table "plans", force: :cascade do |t|
    t.integer  "min_horses"
    t.integer  "max_horses"
    t.string   "details",    null: false
    t.float    "price",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "vat"
  end

  create_table "products", force: :cascade do |t|
    t.string  "country"
    t.integer "price"
    t.integer "vat"
  end

  create_table "push_notifications", force: :cascade do |t|
    t.string   "title",      default: "",    null: false
    t.string   "message",    default: "",    null: false
    t.boolean  "sent",       default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id",                    null: false
    t.index ["sent"], name: "index_push_notifications_on_sent", using: :btree
    t.index ["user_id"], name: "index_push_notifications_on_user_id", using: :btree
  end

  create_table "push_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_push_tokens_on_token", using: :btree
  end

  create_table "races", force: :cascade do |t|
    t.integer "common_horse_id"
    t.integer "race_position"
    t.string  "track"
    t.float   "earnings"
    t.date    "date"
    t.index ["common_horse_id"], name: "index_races_on_common_horse_id", using: :btree
    t.index ["date"], name: "index_races_on_date", using: :btree
  end

  create_table "read_feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "feedback_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["created_at"], name: "index_read_feedbacks_on_created_at", using: :btree
    t.index ["feedback_id"], name: "index_read_feedbacks_on_feedback_id", using: :btree
    t.index ["updated_at"], name: "index_read_feedbacks_on_updated_at", using: :btree
    t.index ["user_id", "feedback_id"], name: "index_read_feedbacks_on_user_id_and_feedback_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_read_feedbacks_on_user_id", using: :btree
  end

  create_table "setup_topics", force: :cascade do |t|
    t.integer  "stable_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stable_id", "title"], name: "index_setup_topics_on_stable_id_and_title", using: :btree
    t.index ["stable_id"], name: "index_setup_topics_on_stable_id", using: :btree
  end

  create_table "share_a_horses", force: :cascade do |t|
    t.integer  "owner_identifier"
    t.string   "owner_email"
    t.text     "data"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "sign_ups", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "telephone"
    t.string   "zip"
    t.string   "city"
    t.integer  "trainer_id"
    t.boolean  "active"
    t.string   "cvr"
    t.string   "locale"
    t.integer  "plan_id"
    t.integer  "stable_type_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "stable_types", force: :cascade do |t|
    t.string   "stable_type", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "stables", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "address",                        null: false
    t.string   "telephone",                      null: false
    t.string   "zip",                            null: false
    t.string   "city",                           null: false
    t.integer  "trainer_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "deleted_at"
    t.boolean  "active",         default: false
    t.string   "cvr"
    t.string   "locale",         default: "da"
    t.integer  "plan_id"
    t.integer  "stable_type_id", default: 2
    t.index ["active"], name: "index_stables_on_active", using: :btree
    t.index ["deleted_at"], name: "index_stables_on_deleted_at", using: :btree
    t.index ["plan_id"], name: "index_stables_on_plan_id", using: :btree
    t.index ["stable_type_id"], name: "index_stables_on_stable_type_id", using: :btree
  end

  create_table "stables_users", id: false, force: :cascade do |t|
    t.integer "user_id",   null: false
    t.integer "stable_id", null: false
    t.index ["stable_id", "user_id"], name: "index_stables_users_on_stable_id_and_user_id", using: :btree
  end

  create_table "tag_types", force: :cascade do |t|
    t.string   "title",      default: "custom", null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "tag_type_id"
    t.string   "tag_name",    default: "", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "stable_id"
    t.index ["created_at"], name: "index_tags_on_created_at", using: :btree
    t.index ["stable_id"], name: "index_tags_on_stable_id", using: :btree
    t.index ["tag_type_id"], name: "index_tags_on_tag_type_id", using: :btree
    t.index ["updated_at"], name: "index_tags_on_updated_at", using: :btree
  end

  create_table "tags_tasks", id: false, force: :cascade do |t|
    t.integer "tag_id",  null: false
    t.integer "task_id", null: false
    t.index ["tag_id", "task_id"], name: "index_tags_tasks_on_tag_id_and_task_id", using: :btree
  end

  create_table "tags_templates", id: false, force: :cascade do |t|
    t.integer "tag_id",      null: false
    t.integer "template_id", null: false
    t.index ["template_id", "tag_id"], name: "index_tags_templates_on_template_id_and_tag_id", using: :btree
  end

  create_table "task_images", force: :cascade do |t|
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "task_id",            null: false
    t.string   "image_dimensions"
    t.index ["task_id"], name: "index_task_images_on_task_id", using: :btree
  end

  create_table "task_logs", force: :cascade do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.string   "key",         default: ""
    t.string   "from",        default: ""
    t.string   "to",          default: ""
    t.string   "custom_name", default: ""
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["created_at"], name: "index_task_logs_on_created_at", using: :btree
    t.index ["custom_name"], name: "index_task_logs_on_custom_name", using: :btree
    t.index ["from"], name: "index_task_logs_on_from", using: :btree
    t.index ["key"], name: "index_task_logs_on_key", using: :btree
    t.index ["task_id"], name: "index_task_logs_on_task_id", using: :btree
    t.index ["to"], name: "index_task_logs_on_to", using: :btree
    t.index ["updated_at"], name: "index_task_logs_on_updated_at", using: :btree
    t.index ["user_id"], name: "index_task_logs_on_user_id", using: :btree
  end

  create_table "tasks", force: :cascade do |t|
    t.string   "taskable_type"
    t.integer  "taskable_id"
    t.integer  "horse_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.date     "date"
    t.time     "time"
    t.text     "note"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.string   "title"
    t.integer  "stable_id"
    t.integer  "type_id"
    t.integer  "completed_by_id"
    t.datetime "completed_at"
    t.string   "internal_note"
    t.integer  "updated_by_id"
    t.integer  "permission"
    t.index ["completed_at"], name: "index_tasks_on_completed_at", using: :btree
    t.index ["completed_by_id"], name: "index_tasks_on_completed_by_id", using: :btree
    t.index ["created_at"], name: "index_tasks_on_created_at", using: :btree
    t.index ["date", "time"], name: "index_tasks_on_date_and_time", using: :btree
    t.index ["deleted_at"], name: "index_tasks_on_deleted_at", using: :btree
    t.index ["horse_id"], name: "index_tasks_on_horse_id", using: :btree
    t.index ["permission"], name: "index_tasks_on_permission", using: :btree
    t.index ["stable_id"], name: "index_tasks_on_stable_id", using: :btree
    t.index ["taskable_id"], name: "index_tasks_on_taskable_id", using: :btree
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id", using: :btree
    t.index ["type_id"], name: "index_tasks_on_type_id", using: :btree
    t.index ["updated_at"], name: "index_tasks_on_updated_at", using: :btree
    t.index ["user_id"], name: "index_tasks_on_user_id", using: :btree
  end

  create_table "templates", force: :cascade do |t|
    t.integer  "stable_id"
    t.integer  "tag_type_id"
    t.string   "name",                         null: false
    t.string   "note"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "prefilled_title", default: ""
    t.index ["stable_id"], name: "index_templates_on_stable_id", using: :btree
    t.index ["tag_type_id"], name: "index_templates_on_tag_type_id", using: :btree
  end

  create_table "token_users", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_token_users_on_user_id", using: :btree
  end

  create_table "trainers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_stable_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "stable_id"
    t.string   "role"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["deleted_at"], name: "index_user_stable_roles_on_deleted_at", using: :btree
    t.index ["stable_id", "user_id"], name: "index_user_stable_roles_on_stable_id_and_user_id", using: :btree
    t.index ["stable_id"], name: "index_user_stable_roles_on_stable_id", using: :btree
    t.index ["user_id"], name: "index_user_stable_roles_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                           default: "",    null: false
    t.string   "username",                       default: "",    null: false
    t.string   "email",                                          null: false
    t.string   "crypted_password",                               null: false
    t.string   "password_salt",                                  null: false
    t.string   "persistence_token",                              null: false
    t.string   "single_access_token",                            null: false
    t.string   "perishable_token",                               null: false
    t.integer  "login_count",                    default: 0,     null: false
    t.integer  "failed_login_count",             default: 0,     null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.datetime "deleted_at"
    t.datetime "public_updated_at"
    t.boolean  "admin",                          default: false
    t.string   "stripe_id"
    t.string   "phone"
    t.string   "address"
    t.string   "zip"
    t.string   "city"
    t.string   "country"
    t.string   "trainer_id"
    t.integer  "import_trainer_id"
    t.boolean  "terms_accepted",                 default: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "push_enabled",                   default: false
    t.boolean  "push_feedback_mention",          default: false
    t.boolean  "push_flagged_horse_feedback",    default: false
    t.boolean  "push_flagged_horse_observation", default: false
    t.boolean  "push_all_horse_feedback",        default: false
    t.boolean  "push_all_horse_observation",     default: false
    t.string   "firstname"
    t.string   "lastname"
    t.string   "owner_identifier"
    t.boolean  "show_reports"
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
    t.index ["firstname"], name: "index_users_on_firstname", using: :btree
    t.index ["import_trainer_id"], name: "index_users_on_import_trainer_id", using: :btree
    t.index ["lastname"], name: "index_users_on_lastname", using: :btree
    t.index ["owner_identifier"], name: "index_users_on_owner_identifier", using: :btree
    t.index ["perishable_token"], name: "index_users_on_perishable_token", using: :btree
    t.index ["single_access_token"], name: "index_users_on_single_access_token", using: :btree
  end

  create_table "users_feedbacks", id: false, force: :cascade do |t|
    t.integer "feedback_id", null: false
    t.integer "user_id",     null: false
    t.index ["feedback_id", "user_id"], name: "index_users_feedbacks_on_feedback_id_and_user_id", using: :btree
  end

  create_table "welcomes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "custom_field_values", "custom_fields"
  add_foreign_key "custom_field_values", "tasks"
  add_foreign_key "custom_fields", "custom_field_types"
  add_foreign_key "custom_fields", "stables"
  add_foreign_key "custom_fields", "tag_types"
  add_foreign_key "images", "users"
  add_foreign_key "ownerships", "common_horses"
  add_foreign_key "ownerships", "users"
end
