class AddToSwfs < ActiveRecord::Migration
  def self.up
    add_column :swfs, :category_id, :string
  end

  def self.down
    remove_column :swfs, :category_id
  end
end
