class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :email
      t.string :hashed_password
      t.string :salt
      t.string :time_zone
      t.string :gender
      t.integer :birthday_day
      t.integer :birthday_month
      t.integer :birthday_year
      t.boolean :email_verified, :default => false
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size
      t.boolean :get_notifications, :default => true
      t.boolean :get_news, :default => true
      t.integer :no_notifications_before, :default => 8
      t.integer :no_notifications_after, :default => 22
      t.datetime :last_logged_in
      t.boolean :use_metric, :default => false
      t.text :bio

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
