class LevelUpRefactor < ActiveRecord::Migration
  # rake db:migrate:up VERSION=20120224193832
  def up
    # Make sure we turn off any notifications for people who aren't admins
    if !Rails.env.production?
      User.update_all(['email = ?, phone = ?, get_notifications = ?', nil, nil, false], ['admin = ?', false])
    end
    # add an active column to program related models
    add_column :program_budges, :active, :boolean, :default => true
    add_column :program_action_templates, :active, :boolean, :default => true
    add_column :auto_messages, :active, :boolean, :default => true

    # program_action_templates
    remove_column :program_action_templates, :duration # It's always 1 day (with 3-day grace period)
    add_column :program_action_templates, :day_number, :integer # nil means every day
    ProgramActionTemplate.all.map{|pat|pat.update_attributes(:day_number => pat.min_day_number)}
    
    add_column :user_actions, :day_number, :integer # nil means every day
    UserAction.all.map{|ua|ua.update_attributes(:day_number => ua.min_day_number)}

    # new level up stuff
    add_column :player_budges, :day_of_budge, :integer, :default => 1
    add_column :player_budges, :day_starts_at, :datetime
    add_column :player_budges, :progress_data, :text
    add_column :player_budges, :num_crows, :integer, :default => 0
    PlayerBudge.update_all(:num_crows => 0)

    # program_player
    remove_column :program_players, :num_snoozes
    remove_column :program_players, :snoozed_at
    remove_column :program_players, :visit_streak
    
    # player_budge
    remove_column :player_budges, :streak_broken
    remove_column :player_budges, :num_daily_reviews
    remove_column :player_budges, :num_times_shared_with_coach
    remove_column :player_budges, :num_times_shared_with_friends
        
    # auto_messages
    remove_column :auto_messages, :day_of_week_number
    remove_column :auto_messages, :trigger_temperature_max
    remove_column :auto_messages, :trigger_temperature_min
    remove_column :auto_messages, :trigger_weather_conditions        

    ProgramBudge.update_all({:active => true})    
    ProgramActionTemplate.update_all({:active => true})    
    AutoMessage.update_all({:active => true})    

    remove_column :program_action_templates, :min_day_number
    remove_column :user_actions, :min_day_number
    
  end

  def down
    add_column :program_players, :num_snoozes, :integer, :default => 0
    add_column :program_players, :snoozed_at, :datetime
    add_column :program_players, :visit_streak, :integer, :default => 0
    remove_column :player_budges, :num_crows

    add_column :player_budges, :streak_broken, :boolean, :default => false
    add_column :player_budges, :num_daily_reviews, :integer, :default => 0
    add_column :player_budges, :num_times_shared_with_coach, :integer, :default => 0
    add_column :player_budges, :num_times_shared_with_friends, :integer, :default => 0
    
    add_column :program_action_templates, :duration, :string
    add_column :program_action_templates, :min_day_number, :integer
    ProgramActionTemplate.all.map{|pat|pat.update_attributes(:min_day_number => pat.day_number)}
    remove_column :program_action_templates, :day_number

    add_column :user_actions, :min_day_number, :integer # nil means every day
    UserAction.all.map{|ua|ua.update_attributes(:min_day_number => ua.day_number)}
    remove_column :user_actions, :day_number
    
    add_column :auto_messages, :day_of_week_number, :integer
    add_column :auto_messages, :trigger_temperature_max, :integer
    add_column :auto_messages, :trigger_temperature_min, :integer
    add_column :auto_messages, :trigger_weather_conditions, :string

    remove_column :program_budges, :active
    remove_column :program_action_templates, :active
    remove_column :auto_messages, :active

    remove_column :player_budges, :day_of_budge
    remove_column :player_budges, :day_starts_at
    remove_column :player_budges, :progress_data
  end
end
