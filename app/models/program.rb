class Program < ActiveRecord::Base
  belongs_to :user
  belongs_to :program_budge
  belongs_to :oauth_token
  has_many :program_coaches, :order => 'total_players DESC', :dependent => :destroy
  has_many :program_link_resources, :dependent => :destroy
  has_many :player_messages, :dependent => :destroy

  has_many :program_budges, :order => :position, :conditions => {:active => true}
  has_many :inactive_program_budges, :order => :position, :conditions => {:active => false}, :class_name => 'ProgramBudge'
  has_many :auto_messages, :conditions => {:active => true}
  has_many :inactive_auto_messages, :conditions => {:active => false}, :class_name => 'AutoMessage'

  has_many :program_players, :dependent => :destroy
  belongs_to :leaderboard_trait, :class_name => 'Trait'
  has_many :leaders
  
  # From http://docs.heroku.com/s3
  has_attached_file :photo, 
    :styles => {:xlarge_scale => "960x960>",
                :xlarge_crop => "960x640#", 
                :large_scale => "480x480>",
                :large_crop => "480x320#", 
                :medium => "164x164#", 
                :small => "82x82#", 
                :tiny => "57x57#"},
    :storage => :s3, 
    :s3_credentials => "#{Rails.root}/config/s3.yml", 
    :path => "/:class/:attachment/:id/:style_:basename.:extension",
    :url => "/:class/:attachment/:id/:style_:basename.:extension",
    :bucket => 'budge_production'

  # Test to see if they have this program 
  def has_been_purchased_by?(user)
    user.program_players.where(:program_id => self.id).present? ? true : false
  end
  
  def first_budge
    self.program_budges.where(:level => 1).order(:position).first
  end
  
  # Find the first budge that is on a higher level
  def next_budge(level)
    budges = self.program_budges.where('level > ?', level).sort_by{|p|p.sort_by}
    if budges.present?
      return budges.first
    else
      # Find the last level
      budges = self.program_budges.order('level desc')
      return budges.first
    end
  end
  
  # After someone has bought a program, run this and it will create a program_player object for them and return it
  def create_program_player(user)
    existing_program_player = user.program_players.where(:program_id => self.id).first
    
    if existing_program_player.present?
      existing_program_player.update_attributes(:active => true, :needs_to_play_at => Time.now.utc)
      program_player = existing_program_player
    else
      program_player = ProgramPlayer.create({:program_id => self.id,
                                             :user_id => user.id,
                                             :needs_to_play_at => Time.now.utc,
                                             :start_date => Time.zone.today})
      program_player.thanks_for_starting
    end
    
    if program_player.present?
      TrackedAction.add(:bought_program, user)
      return program_player
    else
      raise "Unable to create program player."
    end
  end
    
  def select_level_options
    level_array = Array.new
    if self.program_budges.blank?
      level_array << ['Level 1', 1]
    else
      alph = " ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      min_level = self.program_budges.minimum(:level) || 1
      max_level = (self.program_budges.maximum(:level) || 1) + 1
      if min_level == 1
        min_level = -1
      elsif min_level < 0
        min_level = min_level - 1
      end
      
      (min_level..max_level).each do |level|
        if level < 0
          level_array << ["Underground Level #{alph[level.abs,1]}", level]
        elsif level > 0
          level_array << ["Level #{level}", level]        
        end
      end
    end
    return level_array
  end
  
  def update_last_level
    self.update_attributes(:last_level => self.program_budges.maximum(:level))
  end
  
  def self.update_num_playing
    Program.all.each do |program|
      program.update_num_playing
    end
  end
  def update_num_playing
    players = self.program_players
    num_completed = players.select{|pp|pp.completed?}.size
    num_victorious = players.select{|pp|pp.victorious?}.size
    self.update_attributes({:total_players => players.size,
                            :num_active => players.select{|pp|pp.playing?}.size,
                            :num_scheduled => players.select{|pp|pp.scheduled?}.size,
                            :num_budgeless => players.select{|pp|pp.player_budge_id.blank?}.size,
                            :num_completed => num_completed,
                            :num_victorious => num_victorious,
                            :percent_completed => (players.size > 0 ? num_completed.to_f/players.size.to_f : 0),
                            :percent_victorious => (players.size > 0 ? num_victorious.to_f/players.size.to_f : 0),
                            :avg_days_to_completion => nil,
                            :avg_days_to_victory => nil})
  end
  
  def get_program_budges_status
    statuses={}
    self.program_budges.each{|pb| statuses[pb.id]=pb.get_status_count}
    return statuses
  end
  
  
  def get_engagement
    engagement={}
    players=self.program_players
    num_current=players.size - players.select{|pp|pp.completed?}.size
    num_engaged=players.collect{|pp| pp.get_state=="engaged" ? 1 : 0}.sum
    engagement[:count]=num_engaged
    engagement[:percent]=(num_engaged.to_f/num_current.to_f*100).to_i
    return engagement
  end
  
  def leaderboard_ordered_by
    return Leader.ordered_by_words(self.leaderboard_trait_direction)
  end
  
  def leaderboard(date = 1.hour.ago.to_date, offset = 0, limit = 100)
    if self.leaderboard_trait_direction == Leader::DIRECTION_TOTAL_MAX
      sort_by = "score desc"
    elsif self.leaderboard_trait_direction == Leader::DIRECTION_FREQUENCY_MAX
      sort_by = "score desc"
    elsif self.leaderboard_trait_direction == Leader::DIRECTION_AVERAGE_MAX
      sort_by = "score desc"
    elsif self.leaderboard_trait_direction == Leader::DIRECTION_TOTAL_MIN
      sort_by = "score"
    elsif self.leaderboard_trait_direction == Leader::DIRECTION_FREQUENCY_MIN
      sort_by = "score"
    elsif self.leaderboard_trait_direction == Leader::DIRECTION_AVERAGE_MIN
      sort_by = "score"
    end
    self.leaders.where(:date => date).order(sort_by).offset(offset).limit(limit)
  end
  
  def get_trait_statistics
    stats={:sum=>0,:count=>0}
    UserTrait.where(:trait_id=>self.leaderboard_trait_id).each do |user_trait|
      next unless user_trait.present?
      summary_results = user_trait.summary_results() #for last 30 days
      amount =summary_results[:total]
      stats[:sum]+=amount.nil? ? 0 : amount
      stats[:count]+=summary_results[:num_results]
    end
    if stats[:count] > 0
      stats[:average]=stats[:sum]/stats[:count]
    end
    return stats
  end

  def number_levels
    self.program_budges.size
  end
end


# == Schema Information
#
# Table name: programs
#
#  id                          :integer(4)      not null, primary key
#  name                        :string(255)
#  description                 :text
#  token                       :string(255)
#  photo_file_name             :string(255)
#  photo_content_type          :string(255)
#  photo_file_size             :integer(4)
#  system_program              :boolean(1)      default(FALSE)
#  adapted_from_name           :string(255)
#  adapted_from_url            :string(255)
#  user_id                     :integer(4)
#  program_budge_id            :integer(4)
#  total_players               :integer(4)      default(0)
#  num_active                  :integer(4)      default(0)
#  num_snoozing                :integer(4)      default(0)
#  num_completed               :integer(4)      default(0)
#  num_victorious              :integer(4)      default(0)
#  percent_completed           :decimal(5, 2)   default(0.0)
#  percent_victorious          :decimal(5, 2)   default(0.0)
#  avg_days_to_completion      :decimal(7, 2)   default(0.0)
#  avg_days_to_victory         :decimal(7, 2)   default(0.0)
#  num_program_budges          :integer(4)      default(0)
#  created_at                  :datetime
#  updated_at                  :datetime
#  featured                    :boolean(1)      default(FALSE)
#  require_email               :boolean(1)      default(FALSE)
#  require_phone               :boolean(1)      default(FALSE)
#  required_question_1         :string(255)
#  required_question_2         :string(255)
#  optional_question_1         :string(255)
#  optional_question_2         :string(255)
#  price                       :decimal(6, 2)
#  requirements                :text
#  company_name                :string(255)
#  company_url                 :string(255)
#  first_published_on          :date
#  last_published_on           :date
#  program_version             :string(255)
#  avg_star_rating             :decimal(3, 1)
#  maturity_rating             :string(255)
#  welcome_message             :text
#  require_facebook            :boolean(1)      default(FALSE)
#  require_foursquare          :boolean(1)      default(FALSE)
#  require_fitbit              :boolean(1)      default(FALSE)
#  require_withings            :boolean(1)      default(FALSE)
#  introduction_message        :text
#  snooze_message              :text
#  require_runkeeper           :boolean(1)      default(FALSE)
#  completion_message          :text
#  victory_message             :text
#  num_scheduled               :integer(4)      default(0)
#  num_budgeless               :integer(4)      default(0)
#  last_level                  :integer(4)      default(0)
#  onboarding_task             :string(255)
#  leaderboard_trait_id        :integer(4)
#  leaderboard_trait_direction :integer(4)
#

