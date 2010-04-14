class Admin::Galleries::AssetsController < Admin::ResourceController
  
  # GET /admin/galleries/assets
  # GET /admin/galleries/assets.js
  # GET /admin/galleries/assets.xml
  # GET /admin/galleries/assets.json                              AJAX and HTML
  # ---------------------------------------------------------------------------
  # GET /admin/galleries/1/assets
  # GET /admin/galleries/1/assets.js
  # GET /admin/galleries/1/assets.xml
  # GET /admin/galleries/1/assets.json                            AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @assets = Asset.search(params[:search], params[:filter])
    attr_hash =  {
      :only => [:id, :title, :caption, :asset_file_name, :asset_content_type, :asset_file_size, :original_extension] 
    }
    
    if params[:gallery_id]
      @gallery = Gallery.find(params[:gallery_id])
      @assets = @assets - @gallery.images
    end
    
    unless @assets.nil?
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/assets/excerpt', :collection => @assets }
        format.json { render :json => @assets.to_json(attr_hash) }
        format.xml { render :xml => @assets.to_xml(attr_hash) }
      end
    else
      @message = t('assets_empty')
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/assets/empty' }
        format.xml { render :xml => @message, :status => 200 }
        format.json { render :json => @message, :status => 200 }
      end
    end
  end
  
  # GET /admin/galleries/assets/1
  # GET /admin/galleries/assets/1.js
  # GET /admin/galleries/assets/1.xml
  # GET /admin/galleries/assets/1.json                            AJAX and HTML
  #----------------------------------------------------------------------------
  def show
    @asset = Asset.find(params[:id])
    attr_hash =  {
      :only => [:id, :title, :caption, :asset_file_name, :asset_content_type, :asset_file_size, :original_extension] 
    }
    
    if @asset
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/assets/asset', :locals => { :asset => @galleries } }
        format.xml { render :xml => @asset.to_xml(attr_hash) }
        format.json { render :json => @asset.to_json(attr_hash) }
      end
    else
      @message = t('asset_doesnt_exist')
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
  
  # POST /admin/galleries/assets
  # POST /admin/galleries/assets.js
  # POST /admin/galleries/assets.xml
  # POST /admin/galleries/assets.json                             AJAX and HTML
  #----------------------------------------------------------------------------
  def create
    @asset = Asset.new(params[:asset])
    
    if @asset.save
      @asset = Asset.find(@asset.id)
      @asset.update_attributes(params[:asset])
      
      if @asset.asset_content_type.include? "image"
        respond_to do |format|
          format.html { render }
          format.js { 
            responds_to_parent do
              render :update do |page|
                page.insert_html :top, "assets_list", :partial => 'admin/galleries/assets/excerpt', :locals => { :excerpt => @asset }
                page.call('gallery.AssetCreate');
              end
            end
          } 
          format.xml { render :xml => @asset.to_xml(attr_hash) }
          format.json { render :json => @asset.to_json(attr_hash) }
        end
      else
        respond_to do |format|
          @message = t('asset_must_be_image')
          format.html { 
            flash[:error] = @message
            render
          }
          format.js { render :text => @asset.errors.to_json, :status => :unprocessable_entity }
          format.json { render :json => {:message => @message}, :status => :unprocessable_entity }
          format.xml { render :xml => {:message => @message}, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        @message = t('asset_create_failed')
        format.html { 
          flash[:error] = @message
          render
        }
        format.js { render :text => @asset.errors.to_json, :status => :unprocessable_entity }
        format.json { render :json => {:message => @message}, :status => :unprocessable_entity }
        format.xml { render :xml => {:message => @message}, :status => :unprocessable_entity }
      end
    end
    
  end
  
end