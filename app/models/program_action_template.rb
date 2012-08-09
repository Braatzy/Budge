class ProgramActionTemplate < ActiveRecord::Base
  belongs_to :program
  belongs_to :program_budge
  belongs_to :trait
  has_many :user_actions
  acts_as_list :scope => 'program_budge_id = #{program_budge_id} AND day_number = \'#{day_number}\''
  
  REVEAL = {0 => 'all',
            1 => 'one_at_a_time',
            2 => 'on_day_number'}
    
  def sort_by
    return [self.day_number.to_i, self.position, self.id]
  end

  def dont?
    !self.do?
  end
   
  def sample_statement(tense = :past)
    return @statement if @statement.present?
    return "trait info missing" unless self.trait.present? and self.trait.verb.present?
    
    @statement = Trait.statement(User.first, tense, self.trait, 1, nil, prefer_details = true)
    return @statement
  end
  
  def action_wording
    if self.wording.present?
      return self.wording
    else
      return self.name_with_formatting
    end
  end
  
  def question(suppress_help_text=false)
    if self.daily_question.present?
      return self.daily_question
    elsif self.trait and self.trait.daily_question.present?
      return self.trait.daily_question
    elsif suppress_help_text
      return ''
    elsif self.trait.present?
      return "Question needing specification: #{self.trait.verb} : #{self.trait.noun} : #{self.trait.answer_type}"
    else
      return "This trait was deleted."
    end
  end
  
  def name_with_formatting(tense = :future)
    return nil unless self.trait.present?
    self.trait.name_with_formatting((self.do? ? :do : :dont), self.custom_text, self.completion_requirement_number, tense)
  end
  
  def create_actions_for_player_budge(player_budge)
    @user = player_budge.program_player.user
    @user_trait = @user.user_traits.where(:trait_id => self.trait_id).first || UserTrait.create({:user_id => @user.id, :trait_id => self.trait_id})

    # Time in player's time zone
    @time_in_players_time_zone = Time.now.in_time_zone(@user.time_zone_or_default)
    
    @user_action = UserAction.create({
         :user_id => @user.id,
         :trait_id => self.trait_id,
         :user_trait_id => @user_trait.id,
         :program_id => self.program_id,
         :program_budge_id => self.program_budge_id,
         :player_budge_id => player_budge.id,
         :program_action_template_id => self.id,
         :templated_action => true, 
         :name => self.name,
         :custom_text => self.custom_text,
         :do => self.do,
         :completion_requirement_type => self.completion_requirement_type, # Alternates aren't yet implemented (streak, duration_complete)
         :completion_requirement_number => self.completion_requirement_number,
         :day_number => player_budge.day_of_budge
    })
    @user_action.change_status(:started)
    return @user_action
  end
end

# == Schema Information
#
# Table name: program_action_templates
#
#  id                            :integer(4)      not null, primary key
#  program_id                    :integer(4)
#  program_budge_id              :integer(4)
#  position                      :integer(4)      default(1000)
#  trait_id                      :integer(4)
#  name                          :string(255)
#  do                            :boolean(1)
#  completion_requirement_type   :string(255)
#  completion_requirement_number :string(255)
#  custom_text                   :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  daily_question                :string(255)
#  wording                       :string(255)
#  active                        :boolean(1)      default(TRUE)
#  day_number                    :integer(4)
#

