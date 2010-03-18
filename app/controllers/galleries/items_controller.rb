class Galleries::ItemsController < ApplicationController
  radiant_layout 'GalleryItem'
  no_login_required
  
  def show
    @gallery_item = GalleryItem.find(:first, :conditions => ['LOWER(handle) = ?', params[:handle]])
    @title = @gallery_item.title
    
    @radiant_layout = @gallery_item.layout
  end

end