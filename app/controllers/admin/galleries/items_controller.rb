class Admin::Galleries::ItemsController < Admin::ResourceController
  model_class GalleryItem
  
  def index
    @gallery = Gallery.find(params[:gallery_id])
    @gallery_items = @gallery.items
    
    render :partial => 'item', :collection => @gallery_items
  end
  
  def create 
    @gallery = Gallery.find(params[:gallery_id])
    @item = @gallery.items.new(params[:item])
    
    attr_hash =  {
      :include => :gallery,
      :only => [:id, :handle, :title, :caption] 
    }
    
    if @item.save
      respond_to do |format|
        format.json { render :json => @item.to_json(attr_hash) }
      end
    else
      render :text => @item.inspect
    end

  end
  
  def delete
    @item = GalleryItem.find(params[:id])
    @asset = @item.image
    
    if @item.destroy
      respond_to do |format|
        format.json { render :json => @asset.to_json }
      end
    else
      render :text => 'failure'
    end
  end

end