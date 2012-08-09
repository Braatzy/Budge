desc "Test error handling"
task :test_error_handling => :environment do
  begin
    raise "Testing errors."
  rescue => e
    Mailer.message_for_habit_labbers("Error running rake test_error_handling",
                                     e.message,
                                     e).deliver
  end
end

desc "Every 10 minutes stuff"
task :do_frequent_stuff => :environment do
  begin
    User.send_phone_verification_texts
    OauthToken.get_tweets_for_checkin_parsing
  rescue => e
    Mailer.message_for_habit_labbers("Error running User.send_phone_verification_texts",
                                     e.message,
                                     e).deliver
  end
end

desc "Send nags"
task :send_nags => :environment do
  begin 
    NagMode.send_nags
  rescue => e
    Mailer.message_for_habit_labbers("Error running NagMode.send_nags",
                                     e.message,
                                     e).deliver
  end
end

desc "Deliver unsent player messages"
task :deliver_unsent_player_messages => :environment do
  begin
    ProgramPlayer.deliver_unsent_player_messages
  rescue => e
    Mailer.message_for_habit_labbers("Error running ProgramPlayer.deliver_unsent_player_messages",
                                     e.message,
                                     e).deliver
  end
end

desc "Send good morning email"
task :send_good_morning_email => :environment do
  begin
    User.send_good_morning_email
  rescue => e
    Mailer.message_for_habit_labbers("Error running User.send_good_morning_email",
                                     e.message,
                                     e).deliver
  end
end

desc "Pick next nudge times for lazy player"
task :pick_next_nudge_times_for_lazy_players => :environment do
  begin
    User.pick_next_nudge_times_for_lazy_players
  rescue => e
    Mailer.message_for_habit_labbers("Error running User.pick_next_nudge_times_for_lazy_players",
                                     e.message,
                                     e).deliver
  end
end

desc "Send nudge to lazy players"
task :send_nudge_to_lazy_players => :environment do
  begin
    User.send_nudge_to_lazy_players
  rescue => e
    Mailer.message_for_habit_labbers("Error running User.send_nudge_to_lazy_players",
                                     e.message,
                                     e).deliver
  end
end

desc "Budge crows 3 times"
task :budge_crows_three_times => :environment do
  begin
    ProgramPlayer.crow_three_times
  rescue => e
    Mailer.message_for_habit_labbers("Error running ProgramPlayer.crow_three_times",
                                     e.message,
                                     e).deliver
  end
end

desc "Update withings subscriptions"
task :update_withings_subscriptions => :environment do
  begin
    User.update_withings_subscriptions
  rescue => e
    Mailer.message_for_habit_labbers("Error running User.update_withings_subscriptions",
                                     e.message,
                                     e).deliver
  end
end

desc "Visit stats lazy update"
task :visit_stats_lazy_update => :environment do
  begin
    VisitStat.lazy_update
  rescue => e
    Mailer.message_for_habit_labbers("Error running VisitStat.lazy_update",
                                     e.message,
                                     e).deliver
  end
end

desc "Update num playing"
task :update_num_playing_stats => :environment do
  begin
    Program.update_num_playing
    ProgramBudge.update_num_playing
    ProgramCoach.update_num_playing
  rescue => e
    Mailer.message_for_habit_labbers("Error running rake update_num_playing_stats",
                                     e.message,
                                     e).deliver
  end
end

desc "Update twitter scores"
task :update_twitter_scores => :environment do
  begin
    OauthToken.update_twitter_scores
  rescue => e
    Mailer.message_for_habit_labbers("Error running OauthToken.update_twitter_scores",
                                     e.message,
                                     e).deliver
  end
end

desc "Daily GRR"
task :daily_grr => :environment do
  begin
    DailyGrr.save_last_day
  rescue => e
    Mailer.message_for_habit_labbers("Error running DailyGrr.save_last_day",
                                     e.message,
                                     e).deliver
  end
end

desc "Update leaderboards"
task :update_leaderboards => :environment do
  begin
    Leader.update_leaders
  rescue => e
    Mailer.message_for_habit_labbers("Error running Leader.update_leaders",
                                     e.message,
                                     e).deliver
  end
end

desc "Get user states and program player last checkin dates at the end of the day"
task :update_user_states => :environment do
  begin
    ProgramPlayer.update_last_checked_in_for_all_players
    User.update_state_for_all_users
  rescue => e
    Mailer.message_for_habit_labbers("Error running update_user_states",e.message,e).deliver
  end
end

desc "update the metrics for the day"
task :update_metrics => :environment do
  begin 
    #first figure out what day it is.
    #Pacific time midnight is 8hr offset from UTC - if early in UCT "morning" - we actually want metrics from PST's previous day
    now=Time.now.utc
    if now.hour <= 9 
      today=now.to_date-1.day
    else
      today=now.to_date
    end
    
    #then get all the metrics for today
    Metric.acquisition(today)
    Metric.activation(today)
    Metric.retention()
  rescue => e
    Mailer.message_for_habit_labbers("Error running update_metrics",e.message,e).deliver
  end
end