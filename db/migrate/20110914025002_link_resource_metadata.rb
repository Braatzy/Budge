class LinkResourceMetadata < ActiveRecord::Migration
  def self.up
    add_column :link_resources, :photo_file_name, :string
    add_column :link_resources, :photo_content_type, :string
    add_column :link_resources, :photo_file_size, :integer
  end

  def self.down
    remove_column :link_resources, :photo_file_name
    remove_column :link_resources, :photo_content_type
    remove_column :link_resources, :photo_file_size
  end
end
