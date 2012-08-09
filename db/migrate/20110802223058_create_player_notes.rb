class CreatePlayerNotes < ActiveRecord::Migration
  def self.up
    create_table :player_notes do |t|
      t.integer :program_player_id
      t.integer :about_user_id
      t.string :note_about
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :player_notes
  end
end
