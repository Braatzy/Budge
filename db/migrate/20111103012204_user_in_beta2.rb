class UserInBeta2 < ActiveRecord::Migration
  def self.up
    add_column :users, :in_beta, :boolean, :default => false
  end

  def self.down
    remove_column :users, :in_beta
  end
end
