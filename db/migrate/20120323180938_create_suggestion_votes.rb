class CreateSuggestionVotes < ActiveRecord::Migration
  def change
    create_table :suggestion_votes do |t|
      t.integer :suggestion_id
      t.string :email
      t.integer :user_id
      t.boolean :would_play, :default => false
      t.boolean :would_build, :default => false

      t.timestamps
    end
  end
end
