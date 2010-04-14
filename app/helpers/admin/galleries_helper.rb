module Admin::GalleriesHelper
  
  def gallery_available_assets(gallery)
    @assets = Asset.search('', {:image => 1}) - gallery.assets
    
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