class GalleryItem < ActiveRecord::Base
  
  belongs_to :gallery, :class_name => 'Gallery'
  acts_as_list :scope => :gallery
  
  belongs_to :image, :class_name => 'Asset', :foreign_key => 'asset_id'
  
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title, :scope => [:gallery_id]
  validates_uniqueness_of :handle, :scope => [:gallery_id]
  
  attr_accessible :title, :handle, :caption, :slug, :image, :asset_id
  
  before_validation :set_title_handle_and_caption
  before_validation :filter_handle
  
  def slug
    "/gallery/#{self.gallery.handle}/#{self.handle}"
  end
  
  def layout
    gallery.item_layout
  end
  
private
  
  def set_title_handle_and_caption
    self.title = self.image.title if self.title.nil?
    self.handle = self.title if self.handle.nil?
    self.caption = self.image.caption if self.caption.nil?
  end
  
  def filter_handle
    self.handle = self.handle.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
  end
  
end