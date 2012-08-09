class UserActionDayNumber < ActiveRecord::Migration

  # Hijacking this to do this after the big refactor in the previous migration. 
  def up
    PlayerBudge.migrate_to_day_starts_at
  end

  def down
  end
end
