class LocationContextIndex < ActiveRecord::Migration
  def up
    add_index :location_contexts, [:user_id, :created_at]
  end

  def down
    remove_index :location_contexts, [:user_id, :created_at]
  end
end
