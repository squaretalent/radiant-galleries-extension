class Admin::Galleries::AssetsController < Admin::ResourceController
  
  def index
    if params[:gallery_id] == ''
      render :partial => 'denied'
    else  
      @gallery = Gallery.find(params[:gallery_id])
      @assets = Asset.search(nil, params[:filter], nil) - @gallery.images
      
      if @assets.nil?
        render :partial => 'empty'
      else
        render :partial => 'asset', :collection => @assets
      end
    end
  end
  
  def create
    @asset = Asset.new(params[:asset])
    
    if @asset.save
      @asset = Asset.find(@asset.id)
      @asset.update_attributes(params[:asset])
      respond_to do |format|
        format.js {
          responds_to_parent do
            render :update do |page|
              page.insert_html :top, "assets_list", :partial => 'admin/galleries/assets/asset', :asset => @asset
              page.call('gallery.AssetsLatestBind');
              page.call('gallery.AssetFormClear');
            end
          end
        } 
      end
    end
    
  end
  
end