# == Schema Information
#
# Table name: user_likes
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  related_id   :integer(4)      not null
#  related_type :string(255)     not null
#  created_at   :datetime
#  updated_at   :datetime
#

class UserLike < ActiveRecord::Base
  belongs_to :user
  after_create :create_related_comment, :update_related_model

  before_destroy :delete_related_comment
  after_destroy :update_related_model
  
  def related_model
    return @related_model if @related_model
    if self.related_type.to_s == 'user_action'
      @related_model = UserAction.find self.related_id
    end
    return @related_model
  end
  
  def related_user_comment
    return @related_user_comment if @related_user_comment
    @related_user_comment = UserComment.where(:related_id => self.related_id, :related_type => self.related_type, :comment_type => 'like', :comment_type_id => self.id).first rescue nil
    return @related_user_comment  
  end

  # The "user_comment" record that represents this user_like
  def create_related_comment
    if self.related_type == 'user_action' and self.related_model
      @user_comment = UserComment.create({:user_id => self.user_id, 
                                          :related_id => self.related_id, 
                                          :related_type => self.related_type, 
                                          :comment_type => 'like', 
                                          :comment_type_id => self.id,
                                          :comment_text => "supports this"})
    end  
  end
  
  def delete_related_comment
    if self.related_type == 'user_action' and self.related_model
      user_comment_like = UserComment.where(:related_id => self.related_id, :related_type => self.related_type, :comment_type => 'like', :comment_type_id => self.id) 
      logger.warn user_comment_like.inspect
      user_comment_like.destroy_all if user_comment_like.present?
    end
  end
  
  def update_related_model
    if self.related_type == 'user_action' and self.related_model
      new_count = UserLike.where(:related_id => self.related_id, :related_type => self.related_type).count
      self.related_model.update_attributes({:num_supporters => new_count})
    end
  end
end
