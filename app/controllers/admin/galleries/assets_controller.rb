class Admin::Galleries::AssetsController < Admin::ResourceController
  
  def index
    @gallery = Gallery.find(params[:gallery_id])
    
    @assets = Asset.search(nil, params[:filter], nil) - @gallery.images

    render :partial => 'asset', :collection => @assets
  end
  
end