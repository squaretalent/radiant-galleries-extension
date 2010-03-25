class Admin::GalleriesController < Admin::ResourceController
  model_class Gallery
  
  # GET /admin/galleries
  # GET /admin/galleries.js                                       AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @galleries = Gallery.all
    @assets = Asset.all
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/excerpt', :collection => @galleries }
    end
  end
  
  # GET /admin/galleries/1
  # GET /admin/galleries/1.js                                     AJAX and HTML
  #----------------------------------------------------------------------------
  def show
    @gallery = Gallery.find(params[:id])
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/gallery', :locals => { :gallery => @gallery } }
    end
  end
  
  # POST /admin/galleries
  # POST /admin/galleries.js                                      AJAX and HTML
  #----------------------------------------------------------------------------
  def create
    @gallery = Gallery.new(params[:gallery])
    
    if @gallery.save
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/shop/categories/excerpt', :locals => { :excerpt => @gallery } }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error] = "Unable to create new gallery."
          render
        }
        format.js { render :text => @gallery.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /admin/galleries/1
  # PUT /admin/galleries/1.js                                     AJAX and HTML
  #----------------------------------------------------------------------------
  def update
    @gallery = Gallery.find(params[:id])
    
    if @gallery.update_attributes(params[:gallery])
      respond_to do |format|
        format.html { 
          flash[:notice] = "Gallery updated successfully."
          render
        }
        format.js { render :partial => '/admin/shop/categories/excerpt', :locals => { :excerpt => @gallery } }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error] = "Unable to update Gallery."
          render
        }
        format.js { render :text => @gallery.errors.to_s, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /admin/galleries/reorder/1
  # PUT /admin/galleries/reorder/1.js                             AJAX and HTML
  #----------------------------------------------------------------------------
  def reorder
    @gallery = Gallery.find(params[:id])
    
    # Wish this was cleaner
    @items = CGI::parse(params[:items])['gallery_items_list[]']
    
    @content = []
    @items.each_with_index do |id, index|
      @content << index
      @gallery.items.update_all(['position=?', index+1], ['id=?', id])
    end
    
    render :text => @content.inspect
  end
  
  # DELETE /admin/galleries/1
  # DELETE /admin/galleries/1.js                                  AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
    @gallery = Gallery.find(params[:id])
    
    if @gallery and @gallery.destroy
      @message = "Gallery deleted successfully."
      respond_to do |format|
        format.html {
          flash[:notice] = @message
          redirect_to admin_galleries_path
        }
        format.js { render :text => @message, :status => 200 }
      end
    else
      @message = "Unable to delete Gallery."
      respond_to do |format|
        format.html {
          flash[:error] = @message
        }
        format.js { render :text => @message, :status => :unprocessable_entity }
      end
    end
  end

end