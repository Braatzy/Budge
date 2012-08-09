# == Schema Information
#
# Table name: user_comments
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)      not null
#  related_id      :integer(4)      not null
#  related_type    :string(255)     not null
#  comment_text    :text            default(""), not null
#  created_at      :datetime
#  updated_at      :datetime
#  comment_type    :string(255)
#  comment_type_id :string(255)
#

class UserComment < ActiveRecord::Base
  belongs_to :user
  after_create :update_related_model  
  after_destroy :update_related_model
  
  def related_model
    return @related_model if @related_model
    if self.related_type.to_s == 'user_action'
      @related_model = UserAction.find self.related_id
    end
    return @related_model
  end
  
  def update_related_model
    if self.related_type == 'user_action' and self.related_model
      new_count = UserComment.where(:related_id => self.related_id, :related_type => self.related_type).count
      self.related_model.update_attributes({:num_comments => new_count})
    end
  end  
end
