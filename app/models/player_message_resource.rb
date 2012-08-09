# == Schema Information
#
# Table name: player_message_resources
#
#  id                :integer(4)      not null, primary key
#  player_message_id :integer(4)
#  link_resource_id  :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#

class PlayerMessageResource < ActiveRecord::Base
  belongs_to :player_message
  belongs_to :link_resource
end
