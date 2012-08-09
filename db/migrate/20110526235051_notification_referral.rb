class NotificationReferral < ActiveRecord::Migration
  def self.up
    add_column :notifications, :ref_site, :string
    add_column :notifications, :ref_url, :string
  end

  def self.down
    remove_column :notifications, :ref_site
    remove_column :notifications, :ref_url
  end
end
