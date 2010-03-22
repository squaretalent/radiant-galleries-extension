class Admin::Galleries::ItemsController < Admin::ResourceController
  model_class GalleryItem

  def index
    @gallery = Gallery.find(params[:id])
    @gallery_items = @gallery.items
    
    render :partial => 'item', :collection => @gallery_items
  end
  
  def create 
    @gallery = Gallery.find(params[:id])
    @item = @gallery.items.new(params[:item])
    
    if @item.save
      render :text => @gallery.id
    else
      render :text => 'nope'
    end

  end

end