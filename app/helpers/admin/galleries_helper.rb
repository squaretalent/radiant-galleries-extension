module Admin::GalleriesHelper
  
  def gallery_available_assets(gallery)
    @assets = Asset.find_all_by_asset_content_type(Mime::IMAGE.all_types) - gallery.assets
    
    if false
      @result = []
      @assets.each do |asset|
        @result << asset if asset.gallery_items.empty?
      end
    else
      @result = @assets
    end
    @result
  end
  
end