class SupporterUserName < ActiveRecord::Migration
  def self.up
    remove_column :supporters, :user_data
    remove_column :supporters, :invitation_data
    add_column :supporters, :user_name, :string
    add_column :supporters, :invite_message, :text
  end

  def self.down
    remove_column :supporters, :user_name
    remove_column :supporters, :invite_message
    add_column :supporters, :invitation_data, :text    
    add_column :supporters, :user_data, :text
  end
end
