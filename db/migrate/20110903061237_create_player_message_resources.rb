class CreatePlayerMessageResources < ActiveRecord::Migration
  def self.up
    create_table :player_message_resources do |t|
      t.integer :player_message_id
      t.integer :link_resource_id

      t.timestamps
    end
  end

  def self.down
    drop_table :player_message_resources
  end
end
