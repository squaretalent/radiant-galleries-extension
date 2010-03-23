class Admin::GalleriesController < Admin::ResourceController
  model_class Gallery

  def index
    @galleries = Gallery.all
    @assets = Asset.all
  end
  
  def create
    @gallery = Gallery.new(params[:gallery])
    
    if @gallery.save
      respond_to do |format|
        format.js {
          responds_to_parent do
            render :update do |page|
              page.insert_html :bottom, "galleries_list", :partial => 'admin/galleries/gallery', :gallery => @gallery
              page.call('gallery.GalleriesLatestBind');
            end
          end
        }
      end
    else
      render :text => "Gallery could not be created"
    end
    
  end
  
  def update
    @gallery = Gallery.find(params[:id])
    
    if @gallery.update_attributes(params[:gallery])
      respond_to do |format|
        format.js {
          responds_to_parent do
            render :update do |page|
              page.call('gallery.GalleriesUpdate');
            end
          end
        }
      end
    else
      render :text => "Gallery could not be saved"
    end
  end
  
  def reorder
    @gallery = Gallery.find(params[:id])
    @items = CGI::parse(params[:items])['gallery_items_list[]'] # Wish this was cleaner 
    
    @content = []
    @items.each_with_index do |id, index|
      @content << index
      @gallery.items.update_all(['position=?', index+1], ['id=?', id])
    end
    
    render :text => @content.inspect
    
  end

end