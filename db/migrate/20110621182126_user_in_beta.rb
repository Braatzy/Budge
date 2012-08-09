class UserInBeta < ActiveRecord::Migration
  def self.up
    rename_column :users, :contact_on_dev, :in_beta
  end

  def self.down
    rename_column :users, :in_beta, :contact_on_dev
  end
end
