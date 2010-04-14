class Admin::GalleriesController < Admin::ResourceController
  model_class Gallery
  
  # GET /admin/galleries
  # GET /admin/galleries.js
  # GET /admin/galleries.xml
  # GET /admin/galleries.json                                     AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @galleries = Gallery.all
    attr_hash = {
      :include => :images,
      :only => [ :id, :handle, :created_at, :updated_at ]
    }
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/excerpt', :collection => @galleries }
      format.xml { render :xml => @galleries.to_xml(attr_hash) }
      format.json { render :json => @galleries.to_json(attr_hash) }
    end
  end
  
  # GET /admin/galleries/1
  # GET /admin/galleries/1.js
  # GET /admin/galleries/1.xml
  # GET /admin/galleries/1.json                                   AJAX and HTML
  #----------------------------------------------------------------------------
  def show
    @gallery = Gallery.find(params[:id])
    attr_hash = {
      :include => :images,
      :only => [ :id, :handle, :created_at, :updated_at ]
    }
    
    if @gallery
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/gallery', :locals => { :gallery => @gallery } }
        format.xml { render :xml => @gallery.to_xml(attr_hash) }
        format.json { render :json => @gallery.to_json(attr_hash) }
      end
    else
      @message = t('gallery_doesnt_exist')
      respond_to do |format|
        format.html { 
          flash[:error] = @message
          redirect_to admin_galleries_path
        }
        format.js { render :text => @message, :status => :unprocessable_entity }
        format.xml { render :xml => { :message => @message}, :status => :unprocessable_entity }
        format.json { render :json => { :message => @message} , :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /admin/galleries/sort
  # PUT /admin/galleries/sort.js
  # PUT /admin/galleries/sort.xml
  # PUT /admin/galleries/sort.json                                AJAX and HTML
  #----------------------------------------------------------------------------
  def sort
    @galleries = CGI::parse(params[:items])['items_list[]']
    @galleries.each_with_index do |id, index|
      Gallery.update_all(['position=?', index+1], ['id=?', id])
    end
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/excerpt', :collection => @galleries }
      format.xml { render :xml => @shop_product.to_xml(attr_hash) }
      format.json { render :json => @shop_product.to_json(attr_hash) }
    end
  end
  
  # POST /admin/galleries
  # POST /admin/galleries.js
  # POST /admin/galleries.xml
  # POST /admin/galleries.json                                    AJAX and HTML
  #----------------------------------------------------------------------------
  def create
    @gallery = Gallery.new(params[:gallery])
    
    if @gallery.save
      respond_to do |format|
        format.html { 
          flash[:notice] = t('gallery_created')
          redirect_to edit_admin_gallery_path(@gallery) if params[:continue]
          redirect_to admin_galleries_path unless params[:continue]
        }
        format.js { render :partial => '/admin/galleries/excerpt', :locals => { :excerpt => @gallery } }
        format.xml { redirect_to '/admin/galleries/' + @gallery.id + '.xml' }
        format.json { redirect_to '/admin/galleries/' + @gallery.id + '.json' }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error] = t('gallery_created_failed')
          render :new
        }
        format.js { render :text => @gallery.errors.to_json, :status => :unprocessable_entity }
        format.xml { render :xml => @gallery.errors.to_xml, :status => :unprocessable_entity }
        format.json { render :json => @gallery.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /admin/galleries/1
  # PUT /admin/galleries/1.js
  # PUT /admin/galleries/1.xml
  # PUT /admin/galleries/1.json                                   AJAX and HTML
  #----------------------------------------------------------------------------
  def update
    @gallery = Gallery.find(params[:id])
    
    if @gallery.update_attributes(params[:gallery])
      respond_to do |format|
        format.html { 
          flash[:notice] = t('gallery_updated')
          redirect_to edit_admin_gallery_path(@gallery) if params[:continue]
          redirect_to admin_galleries_path unless params[:continue]
        }
        format.js { render :partial => '/admin/galleries/excerpt', :locals => { :excerpt => @gallery } }
        format.xml { redirect_to '/admin/galleries/' + @gallery.id + '.xml' }
        format.json { redirect_to '/admin/galleries/' + @gallery.id + '.json' }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error] = t('gallery_updated_failed')
          render :action => 'edit'
        }
        format.js { render :text => @gallery.errors.to_json, :status => :unprocessable_entity }
        format.xml { render :xml => @gallery.errors.to_xml, :status => :unprocessable_entity }
        format.json { render :json => @gallery.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /admin/galleries/1
  # DELETE /admin/galleries/1.js
  # DELETE /admin/galleries/1.xml
  # DELETE /admin/galleries/1.json                                AJAX and HTML
  #----------------------------------------------------------------------------
  def destroy
    @gallery = Gallery.find(params[:id])
    
    if @gallery and @gallery.destroy
      @message = t('gallery_destroyed')
      respond_to do |format|
        format.html {
          flash[:notice] = @message
          redirect_to admin_galleries_path
        }
        format.js { render :text => @message, :status => 200 }
        format.xml { render :xml => { :message => @message }, :status => 200 }
        format.json { render :json => { :message => @message }, :status => 200 }
      end
    else
      @message = t('gallery_destroyed_failed')
      respond_to do |format|
        format.html {
          flash[:error] = @message
          render :remove
        }
        format.js { render :text => @message, :status => :unprocessable_entity }
        format.xml { render :xml => { :message => @message }, :status => :unprocessable_entity }
        format.json { render :json => { :message => @message }, :status => :unprocessable_entity }
      end
    end
  end
  
end