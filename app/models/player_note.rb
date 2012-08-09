# == Schema Information
#
# Table name: player_notes
#
#  id                :integer(4)      not null, primary key
#  program_player_id :integer(4)
#  about_user_id     :integer(4)
#  note_about        :string(255)
#  text              :text
#  created_at        :datetime
#  updated_at        :datetime
#

class PlayerNote < ActiveRecord::Base
  belongs_to :program_player
  belongs_to :about_user, :class_name => 'User'
end
