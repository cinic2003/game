class AddFlashToSwf < ActiveRecord::Migration
  def self.up
    add_column :swfs, :flash_file_name, :string
    add_column :swfs, :flash_content_type, :string
    add_column :swfs, :flash_file_size, :integer
    add_column :swfs, :flash_updated_at, :datetime
  end

  def self.down
    remove_column :swfs, :flash_file_name
    remove_column :swfs, :flash_content_type
    remove_column :swfs, :flash_file_size
    remove_column :swfs, :flash_updated_at
  end
end
