class AddGalleryIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :gallery_id, :integer
  end
  
  def self.down
    remove_column :pages, :gallery_id
  end
end
