class AddDownloadToSwf < ActiveRecord::Migration
  def self.up
    add_column :swfs, :download, :boolean, :default => false
  end

  def self.down
    remove_column :swfs, :download
  end
end
