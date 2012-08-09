# == Schema Information
#
# Table name: program_drafts
#
#  id         :integer(4)      not null, primary key
#  plaintext  :text
#  data       :text
#  version    :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class ProgramDraft < ActiveRecord::Base
  serialize :data
  belongs_to :user
  
  before_save :parse_text_into_data
  
  def parse_text_into_data
    @levels = self.plaintext.split(/-+\s?LEVEL\s?-+/)

    @program = Hash.new
    @program[:details] = ProgramDraft.get_elements(@levels.shift)
    @program[:levels] = Array.new
    @levels.each do |level|
      @challenges = level.split(/-+\s?BUDGE\s?-+/)
      
      @level = Hash.new
      @level[:details] = ProgramDraft.get_elements(@challenges.shift)
      
      if @challenges.present?
        @level[:challenges] = Array.new
        @challenges.each do |challenge|
          @challenge = Hash.new
          @challenge = ProgramDraft.get_elements(challenge)
          @level[:challenges] << @challenge
        end
      end   
      @program[:levels] << @level
    end
    self.data = @program
  end
  
  def self.get_elements(text)
    elements = Hash.new
    
    current_element_name = nil
    text.split(/\n/).each do |line|
      if line.match(/^([A-Z\_]+)\:\s?(.*)$/)
        current_element_name = $1
        elements[current_element_name] = "#{$2}\n"
      elsif current_element_name.present?
        elements[current_element_name] = "#{elements[current_element_name]}#{line}\n"
      end
    end
    elements.each do |k,v|
      elements[k] = v.strip!
    end
    return elements
  end
end
