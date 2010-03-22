class Admin::GalleriesController < Admin::ResourceController
  model_class Gallery

  def index
    @galleries = Gallery.all
    @assets = Asset.all
  end
  
  def reorder
    @gallery = Gallery.find(params[:id])
    @items = CGI::parse(params[:items])['gallery_items_list[]'] # Wish this was cleaner 
    
    @content = []
    @items.each_with_index do |id, index|
      @content << index
      @gallery.items.update_all(['position=?', index+1], ['id=?', id])
    end
    
    render :text => @content.inspect
    
  end

end