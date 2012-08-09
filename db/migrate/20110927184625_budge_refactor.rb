class BudgeRefactor < ActiveRecord::Migration
  def self.up
    # Programs
    remove_column :programs, :group_token
    remove_column :programs, :official
    remove_column :programs, :category_token
    remove_column :programs, :active_message
    remove_column :programs, :completed_message
    remove_column :programs, :successful_message
    remove_column :programs, :contact_coach_frequently
    remove_column :programs, :oauth_token_id

    rename_column :programs, :program_step_id, :program_budge_id
    rename_column :programs, :num_program_steps, :num_program_budges
    
    # Program Steps
    remove_column :program_steps, :on_success_path
    remove_column :program_steps, :parent_id
    remove_column :program_steps, :progress
    remove_column :program_steps, :generation
    remove_column :program_steps, :failed_response_token
    remove_column :program_steps, :failed_id
    remove_column :program_steps, :partial_response_token
    remove_column :program_steps, :partial_id
    remove_column :program_steps, :success_response_token
    remove_column :program_steps, :success_id
    remove_column :program_steps, :trigger_token
    remove_column :program_steps, :trigger_data
    remove_column :program_steps, :start_message

    rename_column :program_steps, :num_budge_templates, :num_action_templates

    # Prompts
    rename_column :prompts, :prompt_type, :auto_message_type
    rename_column :prompts, :program_step_id, :program_budge_id
    
    # Program Link Resources
    rename_column :program_link_resources, :program_step_id, :program_budge_id

    # Program Budge Templates    
    rename_column :program_budge_templates, :program_step_id, :program_budge_id
    
    # Users
    remove_column :users, :max_concurrent_traits
    remove_column :users, :num_concurrent_traits
    remove_column :users, :num_accepted_budges
    remove_column :users, :num_completed_budges
    remove_column :users, :num_ignored_budges
    remove_column :users, :create_next_notification
    remove_column :users, :notification_streak
    remove_column :users, :max_accepted_budges
    remove_column :users, :num_sent_budges
    remove_column :users, :num_sent_budges_completed
    remove_column :users, :num_unaccepted_budges
    remove_column :users, :max_sent_budges_per_day
    remove_column :users, :num_sent_budges_successful
    remove_column :users, :num_successful_budges
    remove_column :users, :num_user_budges
    
    rename_column :users, :total_level_ups, :total_level_up_credits_earned
    rename_column :users, :streak, :visit_streak
    
    # Program Players
    remove_column :program_players, :response_token
    remove_column :program_players, :outcome_token

    rename_column :program_players, :outcome_since, :last_visited_at
    rename_column :program_players, :player_step_id, :player_budge_id

    add_column :program_players, :visit_streak, :integer
    add_column :program_players, :snoozed_at, :datetime
    add_column :program_players, :restart_at, :date
    add_column :program_players, :restart_day_number, :integer

    # Player Steps
    rename_column :player_steps, :program_step_id, :program_budge_id

    remove_column :player_steps, :outcome_token
    remove_column :player_steps, :response_token
    remove_column :player_steps, :response_id
    remove_column :player_steps, :response_sorted_by
    remove_column :player_steps, :num_times_played
    
    add_column :player_steps, :num_stars, :integer
    add_column :player_steps, :start_date, :date
    
    # Player Messages
    rename_column :player_messages, :player_step_id, :player_budge_id
    rename_column :player_messages, :program_step_id, :program_budge_id
    rename_column :player_messages, :prompt_id, :auto_message_id
    
    # User Budges
    remove_column :user_budges, :num_supporters
    remove_column :user_budges, :secret
    remove_column :user_budges, :unread
    remove_column :user_budges, :ignored
    remove_column :user_budges, :accepted
    remove_column :user_budges, :blocked
    remove_column :user_budges, :budge_request_id
    remove_column :user_budges, :expired
    remove_column :user_budges, :short_id
    remove_column :user_budges, :latitude
    remove_column :user_budges, :longitude
    remove_column :user_budges, :remote_user_id
    remove_column :user_budges, :remote_post_id
    remove_column :user_budges, :post_to_facebook
    remove_column :user_budges, :post_to_twitter
    remove_column :user_budges, :created_hour_of_day
    remove_column :user_budges, :created_day_of_week
    remove_column :user_budges, :created_week_of_year
    remove_column :user_budges, :responded_hour_of_day
    remove_column :user_budges, :responded_day_of_week
    remove_column :user_budges, :responded_week_of_year
    remove_column :user_budges, :responded_minutes
    remove_column :user_budges, :num_nonsupporters
    remove_column :user_budges, :total_views
    remove_column :user_budges, :remote_user_name
    
    rename_column :user_budges, :player_step_id, :player_budge_id
    rename_column :user_budges, :program_step_id, :program_budge_id
    
    # User Traits
    remove_column :user_traits, :num_checkins
    remove_column :user_traits, :num_budges_received
    remove_column :user_traits, :num_sent_budges
    remove_column :user_traits, :num_budges_completed
    remove_column :user_traits, :active
    remove_column :user_traits, :num_budges_successful
    remove_column :user_traits, :sum_budges_alignment
    remove_column :user_traits, :num_sent_budges_completed
    remove_column :user_traits, :num_sent_budges_successful
    remove_column :user_traits, :sum_sent_budges_alignment
    
    # Points
    rename_column :points, :user_budge_id, :user_action_id
    
    # Traits
    rename_column :traits, :do_charge, :do
    rename_column :traits, :object, :noun

    remove_column :traits, :element_token
    remove_column :traits, :num_packs
    remove_column :traits, :name_regex
    
    # Checkins
    rename_column :checkins, :is_budgee, :is_player
    rename_column :checkins, :user_budge_id, :user_action_id
    rename_column :checkins, :completed_budge, :completed_action
    rename_column :checkins, :budgee_leveled_up, :player_leveled_up
    rename_column :checkins, :budger_leveled_up, :coach_leveled_up
    
    remove_column :checkins, :disputable_by_id
    remove_column :checkins, :disputed
    remove_column :checkins, :disputed_reason
    remove_column :checkins, :needs_confirmation
    remove_column :checkins, :confirmed
    remove_column :checkins, :post_to_facebook
    remove_column :checkins, :post_to_twitter
    remove_column :checkins, :post_to_foursquare
    remove_column :checkins, :facebook_post_id
    remove_column :checkins, :tweet_id
    remove_column :checkins, :foursquare_checkin_id
    remove_column :checkins, :foursquare_venue_id
    remove_column :checkins, :foursquare_category_id
    
    # Relationships
    remove_column :relationships, :referrred_by_budge_request_id
    remove_column :relationships, :referred_by_budge_id
    remove_column :relationships, :num_given_budges
    remove_column :relationships, :num_accepted_budges
    remove_column :relationships, :num_successful_budges

    # RENAME ALL THE TABLES
    rename_table :program_steps, :program_budges
    rename_table :prompts, :auto_messages
    rename_table :program_budge_templates, :program_action_templates
    rename_table :player_steps, :player_budges
    rename_table :user_budges, :user_actions
  end

  def self.down
    # RENAME ALL THE TABLES
    rename_table :program_budges, :program_steps
    rename_table :auto_messages, :prompts
    rename_table :program_action_templates, :program_budge_templates
    rename_table :player_budges, :player_steps
    rename_table :user_actions, :user_budges

    # Programs
    add_column :programs, :group_token, :string
    add_column :programs, :official, :boolean, :default => false
    add_column :programs, :category_token, :string
    add_column :programs, :active_message, :text
    add_column :programs, :completed_message, :text
    add_column :programs, :successful_message, :text
    add_column :programs, :contact_coach_frequently, :boolean, :default => true
    add_column :programs, :oauth_token_id, :integer 

    rename_column :programs, :program_budge_id, :program_step_id
    rename_column :programs, :num_program_steps, :num_program_budges
    
    # Program Steps
    add_column :program_steps, :on_success_path, :boolean, :default => false
    add_column :program_steps, :parent_id, :integer
    add_column :program_steps, :progress, :integer, :default => 0
    add_column :program_steps, :generation, :integer, :default => 1
    add_column :program_steps, :failed_response_token, :string
    add_column :program_steps, :failed_id, :integer
    add_column :program_steps, :partial_response_token, :string
    add_column :program_steps, :partial_id, :integer
    add_column :program_steps, :success_response_token, :string
    add_column :program_steps, :success_id, :integer 
    add_column :program_steps, :trigger_token, :string
    add_column :program_steps, :trigger_data, :text
    add_column :program_steps, :start_message, :text    
    rename_column :program_steps, :num_action_templates, :num_budge_templates

    # Prompts
    rename_column :prompts, :auto_message_type, :prompt_type
    rename_column :prompts, :program_budge_id, :program_step_id
    
    # Program Link Resources
    rename_column :program_link_resources, :program_budge_id, :program_step_id

    # Program Budge Templates    
    rename_column :program_budge_templates, :program_budge_id, :program_step_id
    
    # Users
    add_column :users, :max_concurrent_traits, :integer, :default => 1
    add_column :users, :num_concurrent_traits, :integer, :default => 0
    add_column :users, :num_accepted_budges, :integer, :default => 0
    add_column :users, :num_completed_budges, :integer, :default => 0
    add_column :users, :num_ignored_budges, :integer, :default => 0
    add_column :users, :create_next_notification, :datetime
    add_column :users, :notification_streak, :integer, :default => 0
    add_column :users, :max_accepted_budges, :integer, :default => 1
    add_column :users, :num_sent_budges, :integer, :default => 0
    add_column :users, :num_sent_budges_completed, :integer, :default => 0
    add_column :users, :num_unaccepted_budges, :integer, :default => 0
    add_column :users, :max_sent_budges_per_day, :integer, :default => 3
    add_column :users, :num_sent_budges_successful, :integer, :default => 0
    add_column :users, :num_successful_budges, :integer, :default => 0
    add_column :users, :num_user_budges, :integer, :default => 0
    
    rename_column :users, :total_level_up_credits_earned, :total_level_ups
    rename_column :users, :visit_streak, :streak
    
    # Program Players
    add_column :program_players, :response_token, :string
    add_column :program_players, :outcome_token, :string

    rename_column :program_players, :last_visited_at, :outcome_since
    rename_column :program_players, :player_budge_id, :player_step_id

    remove_column :program_players, :visit_streak # integer
    remove_column :program_players, :snoozed_at # datetime
    remove_column :program_players, :restart_at # date
    remove_column :program_players, :restart_day_number #integer

    # Player Steps
    rename_column :player_steps, :program_budge_id, :program_step_id
    add_column :player_steps, :outcome_token, :string, :default => 'ACT'
    add_column :player_steps, :response_token, :string, :default => 'TBD'
    add_column :player_steps, :response_id, :integer
    add_column :player_steps, :response_sorted_by, :string
    add_column :player_steps, :num_times_played, :default => 1
    
    remove_column :player_steps, :num_stars #, :integer
    remove_column :player_steps, :start_date #, :date
    
    # Player Messages
    rename_column :player_messages, :player_budge_id, :player_step_id
    rename_column :player_messages, :program_budge_id, :program_step_id
    rename_column :player_messages, :auto_message_id, :prompt_id
    
    # User Budges
    add_column :user_budges, :num_supporters, :integer, :default => 0
    add_column :user_budges, :secret, :boolean, :default => false
    add_column :user_budges, :unread, :boolean, :default => true
    add_column :user_budges, :ignored, :boolean, :default => false
    add_column :user_budges, :accepted, :boolean, :default => false
    add_column :user_budges, :blocked, :boolean, :default => false
    add_column :user_budges, :budge_request_id, :integer
    add_column :user_budges, :expired, :boolean, :default => false
    add_column :user_budges, :short_id, :string
    add_column :user_budges, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :user_budges, :longitude, :decimal, :precision => 15, :scale => 10
    add_column :user_budges, :remote_user_id, :string
    add_column :user_budges, :remote_post_id, :string
    add_column :user_budges, :post_to_facebook, :boolean, :default => false
    add_column :user_budges, :post_to_twitter, :boolean, :default => false
    add_column :user_budges, :created_hour_of_day, :integer
    add_column :user_budges, :created_day_of_week, :integer
    add_column :user_budges, :created_week_of_year, :integer
    add_column :user_budges, :responded_hour_of_day, :integer
    add_column :user_budges, :responded_day_of_week, :integer
    add_column :user_budges, :responded_week_of_year, :integer
    add_column :user_budges, :responded_minutes, :integer
    add_column :user_budges, :num_nonsupporters, :integer, :default => 0
    add_column :user_budges, :total_views, :integer, :default => 0
    add_column :user_budges, :remote_user_name, :string
    
    rename_column :user_budges, :player_budge_id, :player_step_id
    rename_column :user_budges, :program_budge_id, :program_step_id
    
    # User Traits
    add_column :user_traits, :num_checkins, :integer, :default => 0
    add_column :user_traits, :num_budges_received, :integer, :default => 0
    add_column :user_traits, :num_sent_budges, :integer, :default => 0
    add_column :user_traits, :num_budges_completed, :integer, :default => 0
    add_column :user_traits, :active, :boolean, :default => true
    add_column :user_traits, :num_budges_successful, :integer, :default => 0
    add_column :user_traits, :sum_budges_alignment, :integer, :default => 0
    add_column :user_traits, :num_sent_budges_completed, :integer, :default => 0
    add_column :user_traits, :num_sent_budges_successful, :integer, :default => 0
    add_column :user_traits, :sum_sent_budges_alignment, :integer, :default => 0
    
    # Points
    rename_column :points, :user_action_id, :user_budge_id
    
    # Traits
    add_column :traits, :element_token, :string
    rename_column :traits, :do, :do_charge
    add_column :traits, :num_packs, :integer, :default => 0
    add_column :traits, :name_regex, :string
    rename_column :traits, :noun, :object
    
    # Checkins
    rename_column :checkins, :is_player, :is_budgee
    rename_column :checkins, :user_action_id, :user_budge_id
    rename_column :checkins, :user_action_id, :user_budge_id
    rename_column :checkins, :completed_action, :completed_budge
    rename_column :checkins, :player_leveled_up, :budgee_leveled_up
    rename_column :checkins, :coach_leveled_up, :budger_leveled_up
    
    add_column :checkins, :disputable_by_id, :integer
    add_column :checkins, :disputed, :boolean, :default => false
    add_column :checkins, :disputed_reason, :text

    add_column :checkins, :needs_confirmation, :boolean, :default => false
    add_column :checkins, :confirmed, :boolean, :default => false
    add_column :checkins, :post_to_facebook, :boolean, :default => false
    add_column :checkins, :post_to_twitter, :boolean, :default => false
    add_column :checkins, :post_to_foursquare, :boolean, :default => false
    add_column :checkins, :facebook_post_id, :string
    add_column :checkins, :tweet_id, :string
    add_column :checkins, :foursquare_checkin_id, :string
    add_column :checkins, :foursquare_venue_id, :string
    add_column :checkins, :foursquare_category_id, :string
    
    # Relationships 
    add_column :relationships, :referred_by_budge_request_id, :integer
    add_column :relationships, :referred_by_budge_id, :integer
    add_column :relationships, :num_given_budges, :integer, :default => 0
    add_column :relationships, :num_accepted_budges, :integer, :default => 0
    add_column :relationships, :num_successful_budges, :integer, :default => 0
    
  end
end
