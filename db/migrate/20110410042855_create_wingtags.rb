class CreateWingtags < ActiveRecord::Migration
  def self.up
    create_table :wingtags do |t|
      t.integer :user_id
      t.string :token
      t.integer :num_triggers, :default => 0
      t.string :trigger_data
      t.integer :tag_week
      t.integer :tag_month
      t.integer :tag_year

      t.timestamps
    end
  end

  def self.down
    drop_table :wingtags
  end
end
