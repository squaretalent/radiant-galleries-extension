class CreateDefaultConfig < ActiveRecord::Migration
  def self.up
    Radiant::Config['galleries.gallery_layout'] = 'Gallery'
    Radiant::Config['galleries.item_layout']    = 'GalleryItem'
    
    gallery = Layout.create!(:name => 'Gallery')
    gallery_item = Layout.create!(:name => 'GalleryItem')
  end

  def self.down
  end
end
