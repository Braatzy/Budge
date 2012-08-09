class ProgramCoach < ActiveRecord::Base
  belongs_to :program
  belongs_to :user
  belongs_to :primary_oauth_token, :class_name => 'OauthToken'
  has_many :program_players
  
  def self.batch_email
    User.where(:coach => true).each do |u|
      next unless u.program_coaches.present?
      has_valid_program = false
      u.program_coaches.each do |program_coach|
        if program_coach.program.present? and program_coach.program.featured? and program_coach.num_active > 0
          has_valid_program = true
        end
      end
      if has_valid_program
        ProgramCoach.email_batch_report(u)
      end
    end
  end
  def self.email_batch_report(user)
    user.contact_them(:email, :coach_batch_report, user)    
  end

  def self.update_num_playing
    ProgramCoach.all.each do |program_coach|
      program_coach.update_num_playing
    end
  end
  def available_for_coaching?
    self.currently_accepting_applications? and (self.num_active_and_unflagged < self.max_active_and_unflagged)
  end
  def update_num_playing
    players = self.program_players
    num_completed = players.select{|pp|pp.completed?}.size
    num_victorious = players.select{|pp|pp.victorious?}.size
    ratings = players.select{|pp|pp.program_coach_rating.present?}
    total_ratings = ratings.size
    avg_rating = ratings.sum{|pp|pp.program_coach_rating}.to_f / total_ratings if total_ratings > 0
    self.update_attributes({:total_players => players.size,
                            :num_active => players.select{|pp|pp.playing?}.size,
                            :num_active_and_unflagged => players.select{|pp|pp.playing? and !pp.flagged_as_inactive?}.size,
                            :num_flagged => players.select{|pp|pp.flagged_as_inactive?}.size,    
                            :num_scheduled => players.select{|pp|pp.scheduled?}.size,
                            :num_budgeless => players.select{|pp|pp.player_budge_id.blank?}.size,
                            :num_completed => num_completed,
                            :num_victorious => num_victorious,
                            :avg_rating => avg_rating,
                            :percent_completed => (players.size > 0 ? num_completed.to_f/players.size.to_f : 0),
                            :percent_victorious => (players.size > 0 ? num_victorious.to_f/players.size.to_f : 0),
                            :avg_days_to_completion => nil,
                            :avg_days_to_victory => nil})
  end

end

# == Schema Information
#
# Table name: program_coaches
#
#  id                               :integer(4)      not null, primary key
#  program_id                       :integer(4)
#  user_id                          :integer(4)
#  primary_oauth_token_id           :integer(4)
#  price                            :decimal(6, 2)   default(0.0)
#  message                          :text
#  total_players                    :integer(4)      default(0)
#  num_active                       :integer(4)      default(0)
#  num_snoozed                      :integer(4)      default(0)
#  num_completed                    :integer(4)      default(0)
#  num_victorious                   :integer(4)      default(0)
#  percent_victorious               :decimal(5, 2)   default(0.0)
#  avg_days_to_completion           :decimal(7, 2)   default(0.0)
#  avg_days_to_victory              :integer(4)      default(0)
#  avg_rating                       :integer(4)      default(0)
#  level                            :integer(4)      default(1)
#  currently_accepting_applications :boolean(1)      default(FALSE)
#  head_coach                       :boolean(1)      default(FALSE)
#  created_at                       :datetime
#  updated_at                       :datetime
#  percent_completed                :decimal(5, 2)
#  num_scheduled                    :integer(4)      default(0)
#  num_budgeless                    :integer(4)      default(0)
#  coaching_style                   :string(255)
#  num_active_and_unflagged         :integer(4)      default(0)
#  num_flagged                      :integer(4)      default(0)
#  max_active_and_unflagged         :integer(4)      default(10)
#

