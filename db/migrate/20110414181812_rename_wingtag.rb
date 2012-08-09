class RenameWingtag < ActiveRecord::Migration
  def self.up
    rename_table :wingtags, :tracked_actions
  end

  def self.down
    rename_table :tracked_actions, :wingtags
  end
end
