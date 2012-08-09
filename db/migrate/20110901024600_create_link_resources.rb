class CreateLinkResources < ActiveRecord::Migration
  def self.up
    create_table :link_resources do |t|
      t.string :url
      t.string :bitly_url
      t.string :bitly_hash
      t.text :bitly_stats
      t.string :url_title
      t.string :domain
      t.text :description
      t.string :link_type

      t.timestamps
    end
  end

  def self.down
    drop_table :link_resources
  end
end
