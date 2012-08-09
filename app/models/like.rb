class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry
  
  def self.exists_between(user = nil, entry = nil)
    return false unless user.present? and entry.present?
    if Like.where(:user_id => user.id, :entry_id => entry.id).present?
      return true
    else
      return false
    end
  end
  
  def notify_entry_user
    if self.entry.present? and self.entry.user.present?
      return true if self.entry.user_id == self.user_id

      if Rails.env.production?
        self.entry.user.contact_them(:sms, :liked_entry, self)
      else
        # Just send it to the person who did the liking, for testing purposes
        self.user.contact_them(:sms, :liked_entry, self)
      end
    end
  end
end
