class Galleries::ItemsController < ApplicationController
  radiant_layout 'GalleryItem'
  no_login_required
  
  def show
    @gallery = Gallery.find(:first, :conditions => ['LOWER(handle) = ?', params[:gallery_handle]])
    @gallery_item = @gallery.items.find(:first, :conditions => ['LOWER(handle) = ?', params[:handle]])
    @title = @gallery_item.title
    
    @radiant_layout = @gallery_item.layout
  end

end