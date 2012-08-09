class EntryCommentCleanup < ActiveRecord::Migration
  def self.up
    Entry.where(:message_type => :comment).each do |entry|
      entry.destroy
    end
    Entry.where('parent_id is not null').each do |entry|
      entry.destroy
    end
  end

  def self.down
  end
end
