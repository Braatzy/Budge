class ProgramBudge < ActiveRecord::Base
  belongs_to :program

  has_many :program_action_templates, :conditions => {:active => true}
  has_many :inactive_program_action_templates, :conditions => {:active => false}, :class_name => 'ProgramActionTemplate'
  
  has_many :auto_messages, :conditions => {:active => true}
  has_many :inactive_auto_messages, :conditions => {:active => false}, :class_name => 'AutoMessage'
  
  has_many :player_budges, :dependent => :destroy
  has_many :player_messages, :dependent => :destroy
  serialize :trigger_data

  acts_as_list :scope => :program
  #acts_as_tree :foreign_key => :parent_id

  after_save :update_programs_last_level
  after_create :update_program_num_budges
  after_destroy :update_program_num_budges
  
  def sort_by
    return [self.level, self.position, self.id]
  end

  def create_player_budge_for_program_player(program_player)
    program_player.reload
    if program_player.player_budge.blank?
      @player_budge = PlayerBudge.create({:program_player_id => program_player.id,
                                          :program_budge_id => self.id})
      @player_budge.start_player_budge
      return @player_budge
    else
      raise "Need to end the player's current budge first."
    end
  end
  
  def action_templates_for_day_number(day_number)
    self.program_action_templates.where(['day_number is NULL OR day_number = ? OR day_number = ?', 0, day_number]).sort_by{|ac|ac.sort_by}
  end
  
  def auto_messages_for_day_number(day_number)
    self.auto_messages.where(:deliver_trigger => AutoMessage::TRIGGER_DAY_NUMBER).where(['day_number is NULL OR day_number = ? OR day_number = ?', 0, day_number]).sort_by{|a|a.sort_by}
  end

  def auto_messages_with_triggers
    self.auto_messages.where(:deliver_trigger => AutoMessage::TRIGGER_TRAIT).sort_by{|a|a.sort_by}
  end

  def budge_level
    return @budge_level if @budge_level.present?
    @budge_level = "Level #{self.level}"
    other_budges_on_this_level = self.program.program_budges.where(:level => self.level)
    if other_budges_on_this_level.size > 1
      @budge_level += other_budges_on_this_level.index(self).to_s(27).tr("0-9a-q", "A-Z")
    end
    return @budge_level
  end
  
  def budge_name_and_level
    return @budge_name_and_level if @budge_name_and_level.present?
    @budge_name_and_level = self.budge_level
    if self.name.present?
      @budge_name_and_level += ": #{self.name}"
    end
    return @budge_name_and_level
  end
  
  def nickname
    if self.name.present?
      return self.name
    else
      return "#{self.num_action_templates} action(s)"
    end
  end
  
  def update_program_num_budges
    self.program_action_templates.update_all({:active => false})
    self.auto_messages.update_all({:active => false})
    self.program.update_attributes({:num_program_budges => self.program.program_budges.size})
  end

  def duration_in_words
    case duration
      when 'day'
        "24 hours"
      when '3days'
        "3 days"
      when 'week'
        "week"
      when 'month'
        "month"
      else
        "unknown amount of time"
    end
  end

  def duration_in_days
    case duration
      when 'day'
        1
      when '3days'
        3
      when 'week'
        7
      when 'month'
        30
      else
        0
    end
  end
  
  SNOOZE_DURATION = {1 => "24 hours",
                     2 => "2 days",
                     3 => "3 days",
                     4 => "4 days",
                     5 => "5 days",
                     6 => "6 days",
                     7 => "1 week",
                     14 => "2 weeks",
                     21 => "3 weeks",
                     30 => "1 month",
                     61 => "2 months",
                     91 => "3 months",
                     122 => "4 months",
                     183 => "6 months"}
  
  def self.options_for_pause_duration
    [['24 hours',1],['2 days',2],['3 days',3],['4 days',4],['5 days',5],['6 days',6],['1 week',7],['2 weeks',14],['3 weeks',21],['a month',30],['2 months',61],['3 months',91],['4 months',122],['6 months',183]]
  end
  
  # Make sure we keep track of each program's last level
  def update_programs_last_level
    self.program.update_last_level if self.program.present?
  end
  
  # Tracks how many times this budge is played by people.  Does NOT worry if the same person keeps playing it over and over.  Each time counts.
  def self.update_num_playing
    ProgramBudge.all.each do |program_budge|
      program_budge.update_num_playing
    end
  end
  def update_num_playing
    player_budges = self.player_budges
    self.update_attributes({:total_players => player_budges.size,
                            :num_active => player_budges.select{|pb|pb.in_progress?}.size,
                            :num_incomplete => player_budges.select{|pb|pb.time_up?}.size,
                            :num_lost => player_budges.select{|pb|pb.lost?}.size,
                            :num_dropped_out => player_budges.select{|pb|pb.ended_early?}.size,
                            :num_failed => player_budges.select{|pb|!pb.ended_early? && pb.stars_final.present? && pb.stars_final == 0}.size,
                            :num_partial => player_budges.select{|pb|!pb.ended_early? && pb.stars_final.present? && pb.stars_final > 0 && pb.stars_final < 3}.size,
                            :num_success => player_budges.select{|pb|!pb.ended_early? && pb.stars_final.present? && pb.stars_final == 3}.size})
  
  end
  def number_of_actions
    self.program_action_templates.size
  end
  
  #get the counts for each status over the player budges for this level
  STATES=['scheduled', 'in-progress', 'in-past', 'no-show','failed', 'passed','perfect']
  def get_status_count
    player_budges=self.player_budges
    counts=Hash.new
    STATES.each{|s| counts[s]=0}
    player_budges.each{ |pb| counts[pb.get_status]+=1}
    counts['in-past']=counts['no-show']+counts['failed']+counts['passed']+counts['perfect']
    return counts
  end
  
end

# == Schema Information
#
# Table name: program_budges
#
#  id                         :integer(4)      not null, primary key
#  coach_message              :text
#  duration                   :string(255)
#  num_action_templates       :integer(4)
#  total_players              :integer(4)      default(0)
#  position                   :integer(4)      default(1000), not null
#  num_active                 :integer(4)      default(0)
#  num_incomplete             :integer(4)      default(0)
#  num_lost                   :integer(4)      default(0)
#  num_dropped_out            :integer(4)      default(0)
#  num_failed                 :integer(4)      default(0)
#  num_partial                :integer(4)      default(0)
#  num_success                :integer(4)      default(0)
#  created_at                 :datetime
#  updated_at                 :datetime
#  program_id                 :integer(4)
#  name                       :string(255)
#  level                      :integer(4)
#  action_reveal_type         :integer(4)      default(0)
#  available_during_placement :boolean(1)      default(FALSE)
#  active                     :boolean(1)      default(TRUE)
#

