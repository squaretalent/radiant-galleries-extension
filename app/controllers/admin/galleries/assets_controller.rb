class Admin::Galleries::AssetsController < Admin::ResourceController
  
  # GET /admin/galleries/assets
  # GET /admin/galleries/assets.js                                AJAX and HTML
  #----------------------------------------------------------------------------
  def index
    @assets = Asset.search(params[:search], params[:filter])
    
    if params[:gallery_id]
      @gallery = Gallery.find(params[:gallery_id])
      @assets = @assets - @gallery.images
    end
    
    unless @assets.nil?
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/assets/excerpt', :collection => @assets }
      end
    else
      respond_to do |format|
        format.html { render }
        format.js { render :partial => '/admin/galleries/assets/empty' }
      end
    end
  end
  
  # GET /admin/galleries/assets/1
  # GET /admin/galleries/assets/1.js                              AJAX and HTML
  #----------------------------------------------------------------------------
  def show
    @asset = Asset.find(params[:id])
    
    respond_to do |format|
      format.html { render }
      format.js { render :partial => '/admin/galleries/assets/asset', :locals => { :asset => @galleries } }
    end
  end
  
  # POST /admin/galleries/assets
  # POST /admin/galleries/assets.js                               AJAX and HTML
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
        end
      else
        respond_to do |format|
          @message = "Asset must be an image to be useful to Galleries."
          format.html { 
            flash[:error] = @message
            render
          }
          format.js { render :text => @asset.errors.to_json, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        @message = "Unable to create Asset."
        format.html { 
          flash[:error] = @message
          render
        }
        format.js { render :text => @asset.errors.to_json, :status => :unprocessable_entity }
      end
    end
    
  end
  
end