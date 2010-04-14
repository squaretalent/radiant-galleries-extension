class Admin::Galleries::ItemsController < Admin::ResourceController
  model_class GalleryItem
  
  # GET /admin/galleries/1/items
  # GET /admin/galleries/1/items.js
  # GET /admin/galleries/1/items.xml
  # GET /admin/galleries/1/items.json                             AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    if params[:gallery_id]
      @gallery = Gallery.find(params[:gallery_id])
      @gallery_items = @gallery.items
    else
      @gallery_items = GalleryItem.all
    end
    
    attr_hash =  {
      :only => [:id, :title, :caption, :asset_file_name, :asset_content_type, :asset_file_size, :original_extension] 
    }
    
    unless @gallery_items.nil?
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/items/excerpt', :collection => @gallery_items }
        format.json { render :json => @gallery_items.to_json(attr_hash) }
        format.xml { render :xml => @gallery_items.to_xml(attr_hash) }
      end
    else
      @message = t('items_empty')
      respond_to do |format|
        format.html { 
          flash[:error] = @message
          render 
        }
        format.js { render :partial => '/admin/galleries/items/empty' }
        format.json { render :json => { :message => @message } }
        format.xml { render :xml => { :message => @message } }
      end
    end
  end
  
  # GET /admin/galleries/1/items/1
  # GET /admin/galleries/1/items/1.js
  # GET /admin/galleries/1/items/1.xml
  # GET /admin/galleries/1/items/1.json                           AJAX and HTML
  #----------------------------------------------------------------------------
  def show
    @gallery_item = GalleyItem.find(params[:id])
    attr_hash =  {
      :only => [:id, :title, :caption, :asset_file_name, :asset_content_type, :asset_file_size, :original_extension] 
    }
    
    if @gallery_item
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/items/item', :locals => { :item => @gallery_item } }
        format.xml { render @gallery_item.to_xml(attr_hash), :status => 200 }
        format.json { render @gallery_item.to_json(attr_hash), :status => 200 }
      end
    else
      @message = t('item_doesnt_exist')
      respond_to do |format|
        format.html { 
          flash[:error] = @message
          render
        }
        format.js { render :text => @message, :status => :unprocessable_entity }
        format.xml { render :xml => { :message => @message}, :status => :unprocessable_entity }
        format.json { render :json => { :message => @message} , :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /admin/galleries/1/images/sort
  # PUT /admin/galleries/1/images/sort.js
  # PUT /admin/galleries/1/images/sort.xml
  # PUT /admin/galleries/1/images/sort.json                       AJAX and HTML
  #----------------------------------------------------------------------------
  def sort
    @gallery = Gallery.find(params[:gallery_id])
    
    # Wish this was cleaner
    @items = CGI::parse(params[:items])['items_list[]']
    @items.each_with_index do |id, index|
      @gallery.items.update_all(['position=?', index+1], ['id=?', id])
    end
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/items/excerpt', :collection => @gallery.items }
      format.xml { render :xml => @shop_product.to_xml(attr_hash) }
      format.json { render :json => @shop_product.to_json(attr_hash) }
    end
  end
  
  # POST /admin/galleries/1/items
  # POST /admin/galleries/1/items.js
  # POST /admin/galleries/1/items.xml
  # POST /admin/galleries/1/items.json                            AJAX and HTML
  #----------------------------------------------------------------------------
  def create 
    @gallery = Gallery.find(params[:gallery_id])
    @gallery_item = @gallery.items.new(params[:gallery_item])
    
    attr_hash =  {
      :include => :gallery,
      :only => [:id, :handle, :title, :caption] 
    }
    
    if @gallery_item.save
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/items/excerpt', :locals => { :excerpt => @gallery_item } }
        format.xml { render :xml => @gallery_item.to_xml(attr_hash) }
        format.json { render :json => @gallery_item.to_json(attr_hash) }
      end
    else
      @message = t('item_create_failed')
      respond_to do |format|
        format.html { 
          flash[:error] = @message
          render
        }
        format.js { render :text => @gallery_item.errors.to_json, :status => :unprocessable_entity }
        format.json { render :json => {:message => @message}, :status => :unprocessable_entity }
        format.xml { render :xml => {:message => @message}, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /admin/galleries/1/items/1
  # DELETE /admin/galleries/1/items/1.js
  # DELETE /admin/galleries/1/items/1.xml
  # DELETE /admin/galleries/1/items/1.json                        AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
    @gallery_item = GalleryItem.find(params[:id])
    @asset = @gallery_item.asset
    
    if @gallery_item.destroy
      @message = t('item_delete')
      respond_to do |format|
        format.html {
          flash[:notice] = @message
          redirect_to admin_gallery_items_path
        }
        format.js { render :partial => '/admin/galleries/assets/excerpt', :locals => { :excerpt => @asset } }
        format.xml { render :xml => { :message => @message}, :status => 200 }
        format.json { render :json => { :message => @message}, :status => 200 }
      end
    else
      @message = t('item_delete_failed')
      respond_to do |format|
        format.html {
          flash[:error] = @message
          render
        }
        format.js { render :text => @message, :status => :unprocessable_entity }
        format.xml { render :xml => { :message => @message}, :status => :unprocessable_entity }
        format.json { render :xml => { :message => @message}, :status => :unprocessable_entity }
      end
    end
  end

end