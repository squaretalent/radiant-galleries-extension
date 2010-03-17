class GalleryItem < ActiveRecord::Base
  
  belongs_to :gallery, :class_name => 'Gallery'
  acts_as_list :scope => :gallery
  
  belongs_to :image, :class_name => 'Asset', :foreign_key => 'asset_id'
  
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title
  validates_uniqueness_of :handle
  
  def to_param
    handle
  end
  
  def url 
    'gallery/item/#{to_param}'
  end
  
  def layout
    gallery.item_layout
  end
  
end