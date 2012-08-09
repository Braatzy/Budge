# == Schema Information
#
# Table name: program_link_resources
#
#  id                :integer(4)      not null, primary key
#  program_id        :integer(4)
#  link_resource_id  :integer(4)
#  program_budge_id  :integer(4)
#  user_id           :integer(4)
#  short_description :string(255)
#  long_description  :text
#  importance        :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
#

class ProgramLinkResource < ActiveRecord::Base
  belongs_to :program
  belongs_to :link_resource
  belongs_to :program_budge
  belongs_to :user
  
  def self.importance_select_options
    [["Optional",0],["Recommended",1],["Required",2]]
  end
end
