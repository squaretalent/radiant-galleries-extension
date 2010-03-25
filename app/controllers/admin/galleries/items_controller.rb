class Admin::Galleries::ItemsController < Admin::ResourceController
  model_class GalleryItem
  
  # GET /admin/galleries/:id/items
  # GET /admin/galleries/:id/items.js                             AJAX and HTML
  #----------------------------------------------------------------------------  
  def index
    @gallery = Gallery.find(params[:id])
    
    unless @gallery.items.nil?
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/items/excerpt', :collection => @gallery.items }
      end
    else
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/items/empty' }
      end
    end
  end
  
  # GET /admin/galleries/items/:id
  # GET /admin/galleries/items/:id.js                             AJAX and HTML
  #----------------------------------------------------------------------------
  def show
    @gallery_item = GalleyItem.find(params[:id])
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/items/item', :locals => { :item => @gallery_item } }
    end
  end
  
  # POST /admin/galleries/:id/items
  # POST /admin/galleries/:id/items.js                            AJAX and HTML
  #----------------------------------------------------------------------------
  def create 
    @gallery = Gallery.find(params[:id])
    @gallery_item = @gallery.items.new(params[:gallery_item])
    
    attr_hash =  {
      :include => :gallery,
      :only => [:id, :handle, :title, :caption] 
    }
    
    if @gallery_item.save
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/items/excerpt', :locals => { :excerpt => @gallery_item } }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error] = "Unable to create new item."
          render
        }
        format.js { render :text => @gallery_item.errors.to_json, :status => :unprocessable_entity }
      end
    end

  end
  
  # DELETE /admin/galleries/items/:id
  # DELETE /admin/galleries/items/:id.js                          AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
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