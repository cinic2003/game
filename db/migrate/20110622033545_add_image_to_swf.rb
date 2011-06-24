class AddImageToSwf < ActiveRecord::Migration
  def self.up
    add_column :swfs, :image_url, :string
    add_column :swfs, :image_file_name, :string
    add_column :swfs, :image_content_type, :string
    add_column :swfs, :image_file_size, :integer
    add_column :swfs, :image_updated_at, :datetime
  end

  def self.down
    remove_column :swfs, :image_url
    remove_column :swfs, :image_file_name
    remove_column :swfs, :image_content_type
    remove_column :swfs, :image_file_size
    remove_column :swfs, :image_updated_at
  end
end
