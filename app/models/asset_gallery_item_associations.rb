module AssetGalleryItemAssociations
  
  def self.included(base)
    base.class_eval {
      has_many :gallery_items, :class_name => 'GalleryItem', :order => "position ASC", :dependent => :destroy
    }
  end
  
end