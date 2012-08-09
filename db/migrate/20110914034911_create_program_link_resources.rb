class CreateProgramLinkResources < ActiveRecord::Migration
  def self.up
    create_table :program_link_resources do |t|
      t.integer :program_id
      t.integer :link_resource_id
      t.integer :program_step_id
      t.integer :user_id
      t.string :short_description
      t.text :long_description
      t.integer :importance, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :program_link_resources
  end
end
