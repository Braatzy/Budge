class EntryComment < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user
  # after_create :notify_entry_participants
  
  def notify_entry_participants
    if self.entry.present? 
      if self.user_id != self.entry.user_id
        self.entry.user.contact_them(:sms, :entry_comment, self)
      end
    end
    
    # Get all unique commenters
    entry_comments = self.entry.comments
    entry_comments_hash = Hash.new
    entry_comments.each do |entry_comment|
      next if entry_comment.user_id == self.entry.user_id # Skip entry creator
      next if entry_comment.user_id == self.user_id # Skip commenter
      entry_comments_hash[entry_comment.user] = true
    end
    
    # Contact the other participants
    entry_comments_hash.each do |user, truth|
      user.contact_them(:sms, :entry_comment_participant, self)    
    end
  end
end

# == Schema Information
#
# Table name: entry_comments
#
#  id                  :integer(4)      not null, primary key
#  entry_id            :integer(4)
#  user_id             :integer(4)
#  location_context_id :integer(4)
#  message             :text
#  created_at          :datetime
#  updated_at          :datetime
#

