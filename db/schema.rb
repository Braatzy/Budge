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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120429145326) do

  create_table "addons", :force => true do |t|
    t.string   "token"
    t.string   "name"
    t.integer  "visible_at_level",                                     :default => 0
    t.integer  "level_credit_cost",                                    :default => 0
    t.decimal  "dollar_cost",            :precision => 6, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "purchasable",                                          :default => true
    t.string   "description"
    t.integer  "auto_unlocked_at_level"
  end

  create_table "auto_messages", :force => true do |t|
    t.integer  "auto_message_type", :default => 0
    t.integer  "program_id"
    t.integer  "program_budge_id"
    t.integer  "position",          :default => 1000
    t.integer  "user_id"
    t.integer  "status",            :default => 0
    t.string   "subject"
    t.text     "content"
    t.integer  "delivery_window",   :default => 0
    t.integer  "deliver_trigger",   :default => 0
    t.integer  "day_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hour"
    t.boolean  "include_link",      :default => true
    t.integer  "deliver_via",       :default => 0
    t.integer  "trigger_trait_id"
    t.boolean  "active",            :default => true
  end

  create_table "budge_requests", :force => true do |t|
    t.string   "short_id"
    t.integer  "user_id"
    t.integer  "alignment",                                                :default => 0
    t.boolean  "post_to_budge",                                            :default => false
    t.boolean  "post_to_facebook",                                         :default => false
    t.boolean  "post_to_twitter",                                          :default => false
    t.boolean  "post_to_foursquare",                                       :default => false
    t.string   "foursquare_place_id"
    t.string   "message"
    t.integer  "total_views",                                              :default => 0
    t.integer  "foursquare_views",                                         :default => 0
    t.integer  "num_budges",                                               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",                 :precision => 15, :scale => 10
    t.decimal  "longitude",                :precision => 15, :scale => 10
    t.datetime "closes_at"
    t.integer  "created_hour_of_day"
    t.integer  "created_day_of_week"
    t.integer  "created_week_of_year"
    t.string   "facebook_post_id"
    t.string   "tweet_id"
    t.string   "foursquare_checkin_id"
    t.boolean  "delivered",                                                :default => false
    t.string   "foursquare_category_name"
    t.string   "foursquare_category_id"
    t.string   "place_name"
  end

  create_table "button_hits", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "latitude",             :precision => 15, :scale => 10
    t.decimal  "longitude",            :precision => 15, :scale => 10
    t.integer  "num_clicks_this_hour",                                 :default => 0
    t.date     "date"
    t.integer  "hour_of_day"
    t.integer  "day_of_week"
    t.integer  "month_number"
    t.integer  "day_streak"
    t.integer  "response_minutes"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
  end

  create_table "charges", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "amount",             :precision => 6, :scale => 2
    t.string   "item_name"
    t.integer  "item_id"
    t.string   "transaction_id"
    t.string   "transaction_status"
    t.string   "error_message"
    t.integer  "last_four"
    t.string   "vault_token"
    t.string   "subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "charges", ["user_id", "item_name", "item_id"], :name => "user_item_purchase_index"

  create_table "checkins", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "is_player",                                                    :default => true
    t.integer  "user_action_id"
    t.integer  "trait_id",                                                                        :null => false
    t.decimal  "latitude",                     :precision => 15, :scale => 10
    t.decimal  "longitude",                    :precision => 15, :scale => 10
    t.boolean  "did_action",                                                   :default => false
    t.boolean  "desired_outcome",                                              :default => true
    t.text     "comment"
    t.integer  "amount_integer",                                               :default => 0
    t.decimal  "amount_decimal",               :precision => 10, :scale => 2
    t.string   "amount_string"
    t.text     "amount_text"
    t.datetime "checkin_datetime"
    t.boolean  "checkin_datetime_approximate",                                 :default => false
    t.integer  "hour_of_day"
    t.integer  "day_of_week"
    t.integer  "week_of_year"
    t.string   "checkin_via"
    t.integer  "end_clock_remaining"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "player_leveled_up",                                            :default => false
    t.boolean  "coach_leveled_up",                                             :default => false
    t.string   "amount_units"
    t.integer  "user_trait_id",                                                                   :null => false
    t.date     "date"
    t.string   "remote_id"
    t.decimal  "stars_for_participation",      :precision => 11, :scale => 10, :default => 0.0
    t.decimal  "stars_for_mastery",            :precision => 11, :scale => 10, :default => 0.0
    t.decimal  "stars_for_commenting",         :precision => 11, :scale => 10, :default => 0.0
    t.decimal  "stars_total",                  :precision => 11, :scale => 10, :default => 0.0
    t.integer  "player_budge_id"
    t.boolean  "duplicate",                                                    :default => false
    t.integer  "program_player_id"
    t.text     "raw_text"
  end

  create_table "daily_grrs", :force => true do |t|
    t.date     "date",                                                                  :null => false
    t.integer  "signups",                                              :default => 0
    t.integer  "logins_1day",                                          :default => 0
    t.integer  "logins_7day",                                          :default => 0
    t.decimal  "revenue",               :precision => 10, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_users",                                          :default => 0
    t.integer  "invitations_sent",                                     :default => 0
    t.integer  "invitations_redeemed",                                 :default => 0
    t.integer  "notifications_sent",                                   :default => 0
    t.integer  "notifications_clicked",                                :default => 0
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries", :force => true do |t|
    t.integer  "user_id",                                :null => false
    t.integer  "program_player_id"
    t.integer  "program_id"
    t.integer  "program_budge_id"
    t.integer  "player_message_id"
    t.string   "tweet_id"
    t.string   "facebook_post_id"
    t.integer  "location_context_id"
    t.text     "message"
    t.string   "message_type"
    t.integer  "privacy_setting",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "post_to_coach",       :default => false
    t.boolean  "post_to_twitter",     :default => false
    t.boolean  "post_to_facebook",    :default => false
    t.date     "date"
    t.integer  "player_budge_id"
    t.integer  "parent_id"
    t.string   "original_message"
    t.text     "metadata"
    t.integer  "checkin_id"
  end

  add_index "entries", ["user_id", "privacy_setting", "created_at"], :name => "user_privacy_timestamp"

  create_table "entry_comments", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "user_id"
    t.integer  "location_context_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entry_comments", ["entry_id"], :name => "index_entry_comments_on_entry_id"

  create_table "foursquare_categories", :force => true do |t|
    t.string   "category_id"
    t.string   "name"
    t.string   "plural_name"
    t.string   "icon"
    t.string   "parent_id"
    t.string   "parent_category_id"
    t.integer  "num_children",       :default => 0
    t.integer  "level_deep",         :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "trait_token"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "program_id"
    t.string   "token"
    t.string   "email"
    t.integer  "invited_user_id"
    t.boolean  "visited",           :default => false
    t.boolean  "signed_up",         :default => false
    t.boolean  "bought_program",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_player_id"
    t.integer  "notification_id"
    t.text     "message"
  end

  create_table "leaders", :force => true do |t|
    t.integer  "program_id"
    t.integer  "user_id"
    t.date     "date"
    t.decimal  "score",                :precision => 10, :scale => 3
    t.integer  "num_days"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total",                :precision => 10, :scale => 3
    t.decimal  "average",              :precision => 10, :scale => 3
    t.string   "program_status"
    t.integer  "last_played_days_ago"
    t.string   "checkin_string"
  end

  add_index "leaders", ["program_id", "user_id", "date"], :name => "program_user_date"

  create_table "likes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "entry_id",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "link_resources", :force => true do |t|
    t.string   "url"
    t.string   "bitly_url"
    t.string   "bitly_hash"
    t.text     "bitly_stats"
    t.string   "url_title"
    t.string   "domain"
    t.text     "description"
    t.string   "link_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
  end

  create_table "location_contexts", :force => true do |t|
    t.integer  "user_id"
    t.string   "context_about"
    t.integer  "context_id"
    t.decimal  "latitude",               :precision => 15, :scale => 10
    t.decimal  "longitude",              :precision => 15, :scale => 10
    t.integer  "population_density",                                     :default => 0
    t.integer  "temperature_f"
    t.string   "weather_conditions"
    t.text     "simplegeo_context"
    t.string   "foursquare_place_id"
    t.string   "foursquare_category_id"
    t.string   "foursquare_checkin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "foursquare_context"
    t.boolean  "foursquare_guess",                                       :default => false
    t.string   "place_name"
    t.boolean  "possible_duplicate",                                     :default => false
  end

  add_index "location_contexts", ["context_about", "context_id"], :name => "context"
  add_index "location_contexts", ["user_id", "created_at"], :name => "index_location_contexts_on_user_id_and_created_at"
  add_index "location_contexts", ["user_id"], :name => "index_location_contexts_on_user_id"

  create_table "metrics", :force => true do |t|
    t.date     "date"
    t.string   "status_key"
    t.integer  "number"
    t.string   "cohort"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "nag_mode_prompts", :force => true do |t|
    t.integer  "nag_mode_id"
    t.integer  "day_number"
    t.integer  "at_hour"
    t.boolean  "at_wakeup_time", :default => false
    t.boolean  "at_bedtime",     :default => false
    t.string   "via",            :default => "sms"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nag_modes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "num_days",                                  :default => 7
    t.decimal  "price",       :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "short_id"
    t.boolean  "delivered",              :default => false
    t.datetime "delivered_at"
    t.integer  "delivered_hour_of_day"
    t.integer  "delivered_day_of_week"
    t.integer  "delivered_week_of_year"
    t.datetime "responded_at"
    t.integer  "responded_hour_of_day"
    t.integer  "responded_day_of_week"
    t.integer  "responded_week_of_year"
    t.string   "delivered_via"
    t.string   "message_style_token"
    t.text     "message_data"
    t.integer  "responded_minutes"
    t.integer  "total_clicks",           :default => 0
    t.boolean  "responded",              :default => false
    t.boolean  "completed_response",     :default => false
    t.integer  "method_of_response"
    t.boolean  "shared_results",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remote_user_id"
    t.string   "remote_site_token"
    t.string   "remote_post_id"
    t.boolean  "delivered_immediately",  :default => false
    t.integer  "num_signups",            :default => 0
    t.string   "for_object"
    t.integer  "for_id"
    t.boolean  "from_system",            :default => false
    t.integer  "from_user_id"
    t.boolean  "delivered_off_hours",    :default => false
    t.boolean  "broadcast",              :default => false
    t.string   "ref_site"
    t.string   "ref_url"
    t.boolean  "expected_response",      :default => false
  end

  create_table "oauth2_access_tokens", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "refresh_token_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "oauth2_access_tokens", ["client_id"], :name => "index_oauth2_access_tokens_on_client_id"
  add_index "oauth2_access_tokens", ["expires_at"], :name => "index_oauth2_access_tokens_on_expires_at"
  add_index "oauth2_access_tokens", ["token"], :name => "index_oauth2_access_tokens_on_token", :unique => true
  add_index "oauth2_access_tokens", ["user_id"], :name => "index_oauth2_access_tokens_on_user_id"

  create_table "oauth2_authorization_codes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth2_authorization_codes", ["client_id"], :name => "index_oauth2_authorization_codes_on_client_id"
  add_index "oauth2_authorization_codes", ["expires_at"], :name => "index_oauth2_authorization_codes_on_expires_at"
  add_index "oauth2_authorization_codes", ["token"], :name => "index_oauth2_authorization_codes_on_token", :unique => true
  add_index "oauth2_authorization_codes", ["user_id"], :name => "index_oauth2_authorization_codes_on_user_id"

  create_table "oauth2_clients", :force => true do |t|
    t.string   "name"
    t.string   "redirect_uri"
    t.string   "website"
    t.string   "identifier"
    t.string   "secret"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth2_clients", ["identifier"], :name => "index_oauth2_clients_on_identifier", :unique => true

  create_table "oauth2_refresh_tokens", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth2_refresh_tokens", ["client_id"], :name => "index_oauth2_refresh_tokens_on_client_id"
  add_index "oauth2_refresh_tokens", ["expires_at"], :name => "index_oauth2_refresh_tokens_on_expires_at"
  add_index "oauth2_refresh_tokens", ["token"], :name => "index_oauth2_refresh_tokens_on_token", :unique => true
  add_index "oauth2_refresh_tokens", ["user_id"], :name => "index_oauth2_refresh_tokens_on_user_id"

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "site_token"
    t.string   "site_name"
    t.string   "token"
    t.string   "secret"
    t.string   "remote_name"
    t.string   "remote_username"
    t.string   "remote_user_id"
    t.text     "cached_user_info"
    t.datetime "cached_datetime"
    t.boolean  "working",                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "post_pref_on",           :default => false
    t.text     "friend_id_hash"
    t.datetime "friend_id_hash_updated"
    t.string   "latest_dm_id"
    t.boolean  "primary_token",          :default => true
  end

  create_table "pack_traits", :force => true do |t|
    t.integer  "trait_id",                     :null => false
    t.integer  "pack_id",                      :null => false
    t.integer  "level",      :default => 1
    t.integer  "position",   :default => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packs", :force => true do |t|
    t.integer  "num_traits",         :default => 0
    t.boolean  "launched",           :default => false
    t.boolean  "public",             :default => false
    t.boolean  "requires_unlocking", :default => true
    t.string   "do_name"
    t.text     "description"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dont_name"
    t.string   "name"
    t.integer  "position",           :default => 1000
  end

  create_table "player_budges", :force => true do |t|
    t.integer  "program_player_id"
    t.integer  "program_budge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "last_completed_date"
    t.integer  "stars_final"
    t.decimal  "stars_subtotal",      :precision => 11, :scale => 10, :default => 0.0
    t.boolean  "ended_early",                                         :default => false
    t.boolean  "lazy_scheduled",                                      :default => false
    t.integer  "day_of_budge",                                        :default => 1
    t.datetime "day_starts_at"
    t.text     "progress_data"
    t.integer  "num_crows",                                           :default => 0
  end

  create_table "player_message_resources", :force => true do |t|
    t.integer  "player_message_id"
    t.integer  "link_resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "player_messages", :force => true do |t|
    t.integer  "from_user_id"
    t.string   "from_remote_user"
    t.integer  "to_user_id"
    t.string   "to_remote_user"
    t.text     "content"
    t.integer  "program_player_id"
    t.integer  "player_budge_id"
    t.string   "remote_post_id"
    t.text     "message_data"
    t.boolean  "delivered",         :default => false
    t.datetime "deliver_at"
    t.boolean  "from_coach",        :default => false
    t.boolean  "to_coach",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
    t.integer  "program_budge_id"
    t.string   "error"
    t.integer  "send_attempts",     :default => 0
    t.string   "subject"
    t.integer  "auto_message_id"
    t.integer  "delivered_via",     :default => 0
    t.integer  "deliver_via_pref"
    t.integer  "trigger_trait_id"
    t.integer  "entry_id"
    t.boolean  "to_player",         :default => false
    t.boolean  "to_supporters",     :default => false
    t.integer  "checkin_id"
    t.integer  "message_type",      :default => 0
  end

  create_table "player_notes", :force => true do |t|
    t.integer  "program_player_id"
    t.integer  "about_user_id"
    t.string   "note_about"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "program_action_templates", :force => true do |t|
    t.integer  "program_id"
    t.integer  "program_budge_id"
    t.integer  "position",                      :default => 1000
    t.integer  "trait_id"
    t.string   "name"
    t.boolean  "do"
    t.string   "completion_requirement_type"
    t.string   "completion_requirement_number"
    t.string   "custom_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "daily_question"
    t.string   "wording"
    t.boolean  "active",                        :default => true
    t.integer  "day_number"
  end

  create_table "program_budges", :force => true do |t|
    t.text     "coach_message"
    t.string   "duration"
    t.integer  "num_action_templates"
    t.integer  "total_players",              :default => 0
    t.integer  "position",                   :default => 1000,  :null => false
    t.integer  "num_active",                 :default => 0
    t.integer  "num_incomplete",             :default => 0
    t.integer  "num_lost",                   :default => 0
    t.integer  "num_dropped_out",            :default => 0
    t.integer  "num_failed",                 :default => 0
    t.integer  "num_partial",                :default => 0
    t.integer  "num_success",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
    t.string   "name"
    t.integer  "level"
    t.integer  "action_reveal_type",         :default => 0
    t.boolean  "available_during_placement", :default => false
    t.boolean  "active",                     :default => true
  end

  create_table "program_coaches", :force => true do |t|
    t.integer  "program_id"
    t.integer  "user_id"
    t.integer  "primary_oauth_token_id"
    t.decimal  "price",                            :precision => 6, :scale => 2, :default => 0.0
    t.text     "message"
    t.integer  "total_players",                                                  :default => 0
    t.integer  "num_active",                                                     :default => 0
    t.integer  "num_snoozed",                                                    :default => 0
    t.integer  "num_completed",                                                  :default => 0
    t.integer  "num_victorious",                                                 :default => 0
    t.decimal  "percent_victorious",               :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "avg_days_to_completion",           :precision => 7, :scale => 2, :default => 0.0
    t.integer  "avg_days_to_victory",                                            :default => 0
    t.integer  "avg_rating",                                                     :default => 0
    t.integer  "level",                                                          :default => 1
    t.boolean  "currently_accepting_applications",                               :default => false
    t.boolean  "head_coach",                                                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "percent_completed",                :precision => 5, :scale => 2
    t.integer  "num_scheduled",                                                  :default => 0
    t.integer  "num_budgeless",                                                  :default => 0
    t.string   "coaching_style"
    t.integer  "num_active_and_unflagged",                                       :default => 0
    t.integer  "num_flagged",                                                    :default => 0
    t.integer  "max_active_and_unflagged",                                       :default => 10
  end

  create_table "program_drafts", :force => true do |t|
    t.text     "plaintext"
    t.text     "data"
    t.integer  "version"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "program_link_resources", :force => true do |t|
    t.integer  "program_id"
    t.integer  "link_resource_id"
    t.integer  "program_budge_id"
    t.integer  "user_id"
    t.string   "short_description"
    t.text     "long_description"
    t.integer  "importance",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "program_players", :force => true do |t|
    t.integer  "program_id"
    t.integer  "user_id"
    t.integer  "player_budge_id"
    t.datetime "last_visited_at"
    t.datetime "needs_coach_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "wants_to_change"
    t.string   "how_badly"
    t.string   "success_statement"
    t.string   "latest_tweet_id"
    t.boolean  "active",                        :default => true
    t.string   "coach_note"
    t.integer  "num_messages_to_coach",         :default => 0
    t.integer  "num_messages_from_coach",       :default => 0
    t.integer  "level",                         :default => 1
    t.integer  "max_level",                     :default => 1
    t.integer  "coach_user_id"
    t.text     "required_answer_1"
    t.text     "required_answer_2"
    t.text     "optional_answer_1"
    t.text     "optional_answer_2"
    t.date     "restart_at"
    t.integer  "restart_day_number"
    t.boolean  "onboarding_complete",           :default => false
    t.date     "start_date"
    t.text     "coach_data"
    t.integer  "program_coach_id"
    t.text     "score_data"
    t.boolean  "completed",                     :default => false
    t.string   "program_coach_subscription_id"
    t.date     "program_coach_subscribed_at"
    t.integer  "program_coach_rating"
    t.text     "program_coach_testimonial"
    t.boolean  "program_coach_recommended"
    t.datetime "program_coach_rated_at"
    t.datetime "needs_to_play_at"
    t.integer  "num_supporter_invites",         :default => 1
    t.integer  "coach_flag"
    t.boolean  "needs_coach_pitch",             :default => true
    t.boolean  "needs_survey_pitch",            :default => true
    t.text     "testimonial"
    t.integer  "num_invites_sent",              :default => 0
    t.integer  "num_invites_viewed",            :default => 0
    t.integer  "num_invites_accepted",          :default => 0
    t.integer  "num_invites_available",         :default => 1
    t.boolean  "needs_contact_info",            :default => true
    t.integer  "hardcoded_reminder_hour"
    t.datetime "last_checked_in"
    t.boolean  "victorious"
  end

  add_index "program_players", ["program_id", "needs_coach_at"], :name => "index_program_players_on_program_id_and_needs_coach_at"
  add_index "program_players", ["user_id", "program_id"], :name => "user_and_program", :unique => true

  create_table "programs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "token"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.boolean  "system_program",                                            :default => false
    t.string   "adapted_from_name"
    t.string   "adapted_from_url"
    t.integer  "user_id"
    t.integer  "program_budge_id"
    t.integer  "total_players",                                             :default => 0
    t.integer  "num_active",                                                :default => 0
    t.integer  "num_snoozing",                                              :default => 0
    t.integer  "num_completed",                                             :default => 0
    t.integer  "num_victorious",                                            :default => 0
    t.decimal  "percent_completed",           :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "percent_victorious",          :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "avg_days_to_completion",      :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "avg_days_to_victory",         :precision => 7, :scale => 2, :default => 0.0
    t.integer  "num_program_budges",                                        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "featured",                                                  :default => false
    t.boolean  "require_email",                                             :default => false
    t.boolean  "require_phone",                                             :default => false
    t.string   "required_question_1"
    t.string   "required_question_2"
    t.string   "optional_question_1"
    t.string   "optional_question_2"
    t.decimal  "price",                       :precision => 6, :scale => 2
    t.text     "requirements"
    t.string   "company_name"
    t.string   "company_url"
    t.date     "first_published_on"
    t.date     "last_published_on"
    t.string   "program_version"
    t.decimal  "avg_star_rating",             :precision => 3, :scale => 1
    t.string   "maturity_rating"
    t.text     "welcome_message"
    t.boolean  "require_facebook",                                          :default => false
    t.boolean  "require_foursquare",                                        :default => false
    t.boolean  "require_fitbit",                                            :default => false
    t.boolean  "require_withings",                                          :default => false
    t.text     "introduction_message"
    t.text     "snooze_message"
    t.boolean  "require_runkeeper",                                         :default => false
    t.text     "completion_message"
    t.text     "victory_message"
    t.integer  "num_scheduled",                                             :default => 0
    t.integer  "num_budgeless",                                             :default => 0
    t.integer  "last_level",                                                :default => 0
    t.string   "onboarding_task"
    t.integer  "leaderboard_trait_id"
    t.integer  "leaderboard_trait_direction"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "followed_user_id"
    t.boolean  "read",                   :default => false
    t.boolean  "auto",                   :default => false
    t.boolean  "invisible",              :default => false
    t.boolean  "blocked",                :default => false
    t.string   "from"
    t.boolean  "found_on_other_network", :default => false
    t.boolean  "facebook_friends",       :default => false
    t.boolean  "twitter_friends",        :default => false
    t.boolean  "foursquare_friends",     :default => false
    t.boolean  "referred_signup",        :default => false
    t.string   "referred_signup_via"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notified_followee",      :default => false
    t.boolean  "super_follow",           :default => false
  end

  create_table "stream_items", :force => true do |t|
    t.integer  "user_id"
    t.string   "item_type"
    t.integer  "related_id"
    t.integer  "related_sub_id"
    t.text     "text"
    t.text     "data"
    t.boolean  "private",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "suggestion_votes", :force => true do |t|
    t.integer  "suggestion_id"
    t.string   "email"
    t.integer  "user_id"
    t.boolean  "would_play",    :default => false
    t.boolean  "would_build",   :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "suggestions", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "email"
    t.integer  "user_id"
    t.boolean  "active",          :default => true
    t.integer  "num_play_votes",  :default => 0
    t.integer  "num_build_votes", :default => 0
    t.string   "contest_token"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "supporters", :force => true do |t|
    t.integer  "program_player_id"
    t.integer  "program_id"
    t.integer  "user_id"
    t.string   "invite_token"
    t.boolean  "active",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_twitter_username"
    t.string   "user_name"
    t.text     "invite_message"
  end

  create_table "tracked_actions", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.integer  "num_triggers",        :default => 0
    t.string   "trigger_data"
    t.integer  "tag_week"
    t.integer  "tag_month"
    t.integer  "tag_year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_days_this_week",  :default => 0
    t.integer  "num_days_this_month", :default => 0
  end

  create_table "traits", :force => true do |t|
    t.string   "token"
    t.string   "primary_pack_token"
    t.string   "do_name"
    t.string   "dont_name"
    t.integer  "parent_trait_id"
    t.boolean  "setup_required",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "verb"
    t.string   "noun"
    t.string   "answer_type"
    t.string   "daily_question"
    t.string   "noun_pl"
    t.string   "article"
    t.string   "past_template"
    t.string   "hashtag"
  end

  create_table "twitter_scores", :force => true do |t|
    t.date     "date"
    t.integer  "twitter_id"
    t.string   "twitter_screen_name"
    t.decimal  "klout_score",               :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "klout_slope",               :precision => 5, :scale => 2, :default => 0.0
    t.integer  "klout_class_id"
    t.string   "klout_class_name"
    t.decimal  "klout_network_score",       :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "klout_amplification_score", :precision => 5, :scale => 2, :default => 0.0
    t.integer  "klout_true_reach",                                        :default => 0
    t.decimal  "klout_delta_1day",          :precision => 5, :scale => 2, :default => 0.0
    t.decimal  "klout_delta_5day",          :precision => 5, :scale => 2, :default => 0.0
    t.integer  "num_followers",                                           :default => 0
    t.integer  "num_following",                                           :default => 0
    t.integer  "num_tweets",                                              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_actions", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "templated_action",                                             :default => false
    t.integer  "trait_id"
    t.integer  "user_trait_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "do"
    t.string   "name"
    t.string   "completion_requirement_type"
    t.decimal  "completion_requirement_number", :precision => 20, :scale => 2
    t.datetime "last_checkin_at"
    t.string   "custom_text"
    t.integer  "sum_of_amount",                                                :default => 0
    t.integer  "player_budge_id"
    t.integer  "program_budge_id"
    t.integer  "program_id"
    t.integer  "status",                                                       :default => 0
    t.integer  "program_action_template_id"
    t.integer  "num_days_done",                                                :default => 0
    t.integer  "day_number"
  end

  create_table "user_addons", :force => true do |t|
    t.integer  "user_id"
    t.integer  "addon_id"
    t.integer  "level_credits_spent",                                :default => 0
    t.decimal  "dollars_spent",       :precision => 10, :scale => 0, :default => 0
    t.boolean  "activated",                                          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_owned",                                          :default => 1
    t.text     "given_to"
    t.text     "given_by"
  end

  create_table "user_comments", :force => true do |t|
    t.integer  "user_id",         :null => false
    t.integer  "related_id",      :null => false
    t.string   "related_type",    :null => false
    t.text     "comment_text",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment_type"
    t.string   "comment_type_id"
  end

  add_index "user_comments", ["user_id", "related_id", "related_type"], :name => "user_related_id_type"

  create_table "user_likes", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "related_id",   :null => false
    t.string   "related_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_likes", ["user_id", "related_id", "related_type"], :name => "all_fields"

  create_table "user_nag_modes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "nag_mode_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "program_id"
    t.integer  "program_player_id"
    t.boolean  "active",            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_nag_modes", ["start_date", "end_date", "active"], :name => "date_index"

  create_table "user_traits", :force => true do |t|
    t.integer  "user_id",                          :null => false
    t.integer  "trait_id",                         :null => false
    t.integer  "level",             :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "do_points",         :default => 0
    t.integer  "dont_points",       :default => 0
    t.integer  "coach_do_points",   :default => 0
    t.integer  "coach_dont_points", :default => 0
  end

  add_index "user_traits", ["user_id", "trait_id"], :name => "user_and_trait", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email",                                                          :default => "",           :null => false
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "time_zone"
    t.string   "gender"
    t.integer  "birthday_day"
    t.integer  "birthday_month"
    t.integer  "birthday_year"
    t.boolean  "email_verified",                                                 :default => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.boolean  "get_notifications",                                              :default => true
    t.boolean  "get_news",                                                       :default => true
    t.integer  "no_notifications_before",                                        :default => 8
    t.integer  "no_notifications_after",                                         :default => 22
    t.datetime "last_logged_in"
    t.boolean  "use_metric",                                                     :default => false
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "facebook_uid"
    t.boolean  "admin",                                                          :default => false
    t.string   "relationship_status"
    t.integer  "level_up_credits",                                               :default => 0
    t.integer  "num_notifications",                                              :default => 0
    t.integer  "total_level_up_credits_earned",                                  :default => 0
    t.integer  "meta_level",                                                     :default => 0
    t.string   "phone"
    t.string   "phone_normalized"
    t.boolean  "phone_verified",                                                 :default => false
    t.string   "facebook_username"
    t.string   "twitter_username"
    t.integer  "contact_by_email_pref",                                          :default => 10
    t.integer  "contact_by_sms_pref",                                            :default => 10
    t.integer  "contact_by_public_tweet_pref",                                   :default => 5
    t.integer  "contact_by_dm_tweet_pref",                                       :default => 5
    t.integer  "contact_by_robocall_pref",                                       :default => 0
    t.decimal  "contact_by_email_score",         :precision => 10, :scale => 8,  :default => 10.0
    t.decimal  "contact_by_sms_score",           :precision => 10, :scale => 8,  :default => 10.0
    t.decimal  "contact_by_public_tweet_score",  :precision => 10, :scale => 8,  :default => 10.0
    t.decimal  "contact_by_dm_tweet_score",      :precision => 10, :scale => 8,  :default => 10.0
    t.decimal  "contact_by_robocall_score",      :precision => 10, :scale => 8,  :default => 10.0
    t.integer  "visit_streak",                                                   :default => 0
    t.decimal  "contact_by_facebook_wall_pref",  :precision => 10, :scale => 8,  :default => 5.0
    t.decimal  "contact_by_facebook_wall_score", :precision => 10, :scale => 8,  :default => 10.0
    t.decimal  "contact_by_friend_pref",         :precision => 10, :scale => 8,  :default => 1.0
    t.decimal  "contact_by_friend_score",        :precision => 10, :scale => 8,  :default => 10.0
    t.integer  "meta_level_alignment"
    t.string   "meta_level_role"
    t.string   "meta_level_name"
    t.text     "addon_cache"
    t.boolean  "coach",                                                          :default => false
    t.datetime "visit_stats_updated"
    t.integer  "visit_stats_sample_size",                                        :default => 0
    t.integer  "streak_level",                                                   :default => 0
    t.boolean  "has_braintree",                                                  :default => false
    t.integer  "distance_units",                                                 :default => 0
    t.integer  "weight_units",                                                   :default => 0
    t.integer  "currency_units",                                                 :default => 0
    t.string   "withings_user_id"
    t.string   "withings_public_key"
    t.string   "withings_username"
    t.date     "withings_subscription_renew_by"
    t.decimal  "last_latitude",                  :precision => 15, :scale => 10
    t.decimal  "last_longitude",                 :precision => 15, :scale => 10
    t.datetime "lat_long_updated_at"
    t.datetime "next_nudge_at"
    t.boolean  "in_beta",                                                        :default => false
    t.integer  "last_location_context_id"
    t.decimal  "dollars_credit",                 :precision => 8,  :scale => 2,  :default => 0.0
    t.boolean  "send_phone_verification",                                        :default => false
    t.string   "status",                                                         :default => "interested"
    t.datetime "officially_started_at"
    t.string   "cohort_tag"
    t.boolean  "invited_to_beta",                                                :default => false
    t.date     "cohort_date"
    t.integer  "wake_hour_utc"
    t.integer  "bed_hour_utc"
    t.string   "encrypted_password",                                             :default => "",           :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                  :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "visit_stats", :force => true do |t|
    t.string   "constrained_by"
    t.string   "constrained_by_id1"
    t.string   "constrained_by_id2"
    t.string   "constrained_by_id3"
    t.integer  "num_visits",                                       :default => 0
    t.decimal  "percent_visits",     :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
