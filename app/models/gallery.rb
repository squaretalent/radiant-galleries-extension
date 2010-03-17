class Gallery < ActiveRecord::Base
  
  has_many :items, :order => 'position', :class_name => 'GalleryItem', :foreign_key => :gallery_id, :dependent => :destroy
  
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title
  validates_uniqueness_of :handle
  
  attr_accessible :title, :handle, :caption, :slug
  
  def slug
    "/gallery/#{self.handle.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')}"
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