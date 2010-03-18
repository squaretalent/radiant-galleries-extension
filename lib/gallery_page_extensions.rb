module GalleryPageExtensions

  def current_gallery
    @current_gallery = Gallery.find(:first, :conditions => {:handle => self.slug})
  end
  
end