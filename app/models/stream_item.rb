# == Schema Information
#
# Table name: stream_items
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  item_type      :string(255)
#  related_id     :integer(4)
#  related_sub_id :integer(4)
#  text           :text
#  data           :text
#  private        :boolean(1)      default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

class StreamItem < ActiveRecord::Base
  serialize :data
  belongs_to :user
  
  def object
    (self.data.present? and self.data[:object].present?) ? self.data[:object] : nil  
  end
  def live_object
    if self.item_type == 'user_budge'
      return UserBudge.find self.related_id
    else
      return nil
    end
  end
end
