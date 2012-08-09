class RelationshipNotify < ActiveRecord::Migration
  def self.up
    add_column :relationships, :notified_followee, :boolean, :default => false
    
    Relationship.update_all(:notified_followee => true)
  end

  def self.down
    remove_column :relationships, :notified_followee
  end
end
