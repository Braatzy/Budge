class CreateProgramDrafts < ActiveRecord::Migration
  def self.up
    create_table :program_drafts do |t|
      t.text :plaintext
      t.text :data
      t.integer :version
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :program_drafts
  end
end
