class CreateSupporters < ActiveRecord::Migration
  def self.up
    create_table :supporters do |t|
      t.integer :program_player_id
      t.integer :program_id
      t.integer :user_id
      t.string :invite_token
      t.boolean :active, :default => false
      t.text :user_data
      t.text :invitation_data

      t.timestamps
    end
  end

  def self.down
    drop_table :supporters
  end
end
