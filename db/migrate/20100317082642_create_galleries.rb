class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.string  :title,   :limit => 255,  :null => false
      t.string  :caption, :limit => 255,  :null => false
      t.string  :handle,  :limit => 255,  :null => false
      
      t.string  :custom_layout, :limit => 255
      t.string  :custom_item_layout, :limit => 255
      
      t.integer :created_by
      t.integer :updated_by
      
      t.timestamps
    end
  end

  def self.down
    drop_table  :galleries
  end
end
