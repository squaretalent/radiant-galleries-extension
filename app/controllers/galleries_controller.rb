class GalleriesController < ApplicationController
  radiant_layout 'Gallery'
  no_login_required
  
  def show
    @gallery = Gallery.find(:first, :conditions => ['LOWER(handle) = ?', params[:handle]]))
    @title = @gallery.title
    
    @radiant_layout = @shop_category.layout
  end

end