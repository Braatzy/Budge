class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.string :title
      t.text :description
      t.string :email
      t.integer :user_id
      t.boolean :active, :default => true
      t.integer :num_play_votes, :default => 0
      t.integer :num_build_votes, :default => 0
      t.string :contest_token

      t.timestamps
    end
  end
end
