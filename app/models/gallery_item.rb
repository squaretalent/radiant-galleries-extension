class GalleryItem < ActiveRecord::Base
  
  belongs_to :gallery, :class_name => 'Gallery'
  acts_as_list :scope => :gallery
  
  belongs_to :image, :class_name => 'Asset', :foreign_key => 'asset_id'
  
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title
  validates_uniqueness_of :handle
  
  attr_accessible :title, :handle, :caption, :slug, :image
  
  def slug
    "/gallery/#{self.gallery.slug_handle}/#{self.slug_handle}"
  end
  
  def slug_handle
    handle.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
  end
  
  def layout
    gallery.item_layout
  end
  
end