class Gallery < ActiveRecord::Base
  
  has_many :items, :class_name => 'GalleryItem', :foreign_key => :gallery_id, :dependent => :destroy
  
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title
  validates_uniqueness_of :handle
  
  def to_param
    handle
  end
  
  def url
    '/gallery/#{to_param}'
  end
  
  def layout
    unless custom_layout.blank?
      custom_layout
    else
      Radiant::Config['galleries.gallery_layout'] || 'Gallery'
    end
  end
  
  def item_layout
    unless custom_item_layout.blank?
      custom_item_layout
    else
      Radiant::Config['galleries.item_layout'] || 'GalleryItem'
    end
  end
  
end