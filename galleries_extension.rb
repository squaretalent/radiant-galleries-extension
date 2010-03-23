# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class GalleriesExtension < Radiant::Extension
  version "1.0.1"
  description "Photo Galleries using the paperclipped extension for assets"
  url "http://github.com/squaretalent/radiant-galleries-extension"

  define_routes do |map|
    map.namespace :admin, :member => {:remove => :get} do |admin|

      map.admin_gallery_assets 'admin/gallery/assets.:format', :controller => 'admin/galleries/assets', :action => 'index', :conditions => { :method => :get }
      map.create_admin_gallery_asset 'admin/gallery/assets/create.:format', :controller => 'admin/galleries/assets', :action => 'create', :conditions => { :method => :post }
      
      map.admin_gallery_items 'admin/gallery/items.:format', :controller => 'admin/galleries/items', :action => 'index', :conditions => { :method => :get }
      map.create_admin_gallery_item 'admin/gallery/items/create.:format', :controller => 'admin/galleries/items', :action => 'create', :conditions => { :method => :post }
      map.delete_admin_gallery_item 'admin/gallery/items/:id/remove.:format', :controller => 'admin/galleries/items', :action => 'remove', :conditions => { :method => :get }
      
      
      map.reorder_admin_gallery 'admin/galleries/:id/reorder.:format', :controller => 'admin/galleries', :action => 'reorder', :conditions => { :method => :put }
      admin.resources :galleries
    end
    map.connect 'gallery/:handle', :controller => 'galleries', :action => 'show'
    map.connect 'gallery/:gallery_handle/:handle', :controller => 'galleries/items', :action => 'show'
  end
  
  extension_config do |config|
    config.gem 'paperclip', :version => '~> 2.3.1.1', :source => 'http://gemcutter.org'
    config.gem 'acts_as_list', :source => 'http://gemcutter.org'
  end
  
  def activate
    
    UserActionObserver.instance
    UserActionObserver.class_eval do
      observe Gallery, GalleryItem
    end
    
    Page.class_eval { include GalleryTags, GalleryItemTags, PageExtensionsForGallery }
    
    tab 'Content' do
      add_item 'Galleries', '/admin/galleries', :after => 'Pages'
    end
    
    admin.page.edit.add :layout_row, 'gallery' if admin.respond_to?(:page)    
  end
end
