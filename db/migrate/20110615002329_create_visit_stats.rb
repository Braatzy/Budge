class CreateVisitStats < ActiveRecord::Migration
  def self.up
    create_table :visit_stats do |t|
      t.string :constrained_by
      t.string :constrained_by_id1
      t.string :constrained_by_id2
      t.string :constrained_by_id3
      t.integer :num_visits, :default => 0
      t.decimal :percent_visits, :default => 0, :precision => 5, :scale => 2

      t.timestamps
    end
    add_index :visit_stats, [:constrained_by, :constrained_by_id1, :constrained_by_id2, :constrained_by_id3], :name => :constraints
    
    add_column :users, :visit_stats_updated, :datetime
    add_column :users, :visit_stats_sample_size, :integer, :default => 0
  end

  def self.down
    drop_table :visit_stats
    remove_column :users, :visit_stats_updated
    remove_column :users, :visit_stats_sample_size
  end
end
