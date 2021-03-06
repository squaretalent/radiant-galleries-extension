class Gallery < ActiveRecord::Base
  
  has_many :items, :order => 'position', :class_name => 'GalleryItem', :foreign_key => :gallery_id, :dependent => :destroy
  has_many :assets, :through => :items
  
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title
  validates_uniqueness_of :handle
  
  attr_accessible :title, :handle, :caption, :slug
  
  before_validation :filter_handle
  
  default_scope :order => 'created_at DESC'
  
  def slug
    "/news/galleries/#{self.handle}"
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
  
  def assets_available
    Asset.search('', {:image => 1}) - self.assets
  end
  
private
  
  def filter_handle
    self.handle = self.title if !self.title.nil? and (self.handle.nil? or self.handle.empty?)
    self.handle = self.handle.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
  end
  
end