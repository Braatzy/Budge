task :cron => :environment do

  # Get all new messages from users and coaches
  # ProgramPlayer.deliver_unsent_player_messages

  # Send daily nudges to anyone who hasn't visited in a while
  # User.pick_next_nudge_times_for_lazy_players
  # User.send_nudge_to_lazy_players
  
  # Once a day for the previous game and the current game
  if Time.now.hour == 1
    # User.update_withings_subscriptions # Make sure our withings subscriptions stay subscribed
  elsif Time.now.hour == 2
    # VisitStat.lazy_update # Figure out the best time to contact people
  elsif Time.now.hour == 3
    # Program.update_num_playing # Stats on how many people are playing, active, completed, victorious, etc
    # ProgramBudge.update_num_playing # Stats on how the budges in each program are doing
    # ProgramCoach.update_num_playing # Stats on how the coaches are doing
  elsif Time.now.hour == 4
    # OauthToken.update_twitter_scores # Update num_followers and klout
  end
  
  # This is slow
  # ProgramPlayer.refresh_all_remote_player_messages

end
