class CreateGalleryItems < ActiveRecord::Migration
  def self.up
    create_table :gallery_items do |t|
      t.string  :title,   :limit => 255,  :null => false
      t.string  :handle,  :limit => 255,  :null => false
      
      t.integer :asset_id
      t.integer :gallery_id
      
      t.integer :position
      
      t.integer :created_by
      t.integer :updated_by
      
      t.timestamps
    end
  end

  def self.down
    drop_table  :gallery_items
  end
end
