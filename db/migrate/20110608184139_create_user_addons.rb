class CreateUserAddons < ActiveRecord::Migration
  def self.up
    create_table :user_addons do |t|
      t.integer :user_id
      t.integer :addon_id
      t.integer :level_credits_spent, :default => 0
      t.decimal :dollars_spent, :default => 0
      t.boolean :activated, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :user_addons
  end
end
