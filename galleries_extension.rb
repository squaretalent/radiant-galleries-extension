# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class GalleriesExtension < Radiant::Extension
  version "1.0.1"
  description "Photo Galleries using the paperclipped extension for assets"
  url "http://github.com/squaretalent/radiant-galleries-extension"

  define_routes do |map|
    map.namespace :admin, :member => {:remove => :get} do |admin|

      map.sort_admin_gallery 'admin/galleries/sort/:id.:format', :controller => 'admin/galleries', :action => 'reorder', :conditions => { :method => :put }
      
      admin.namespace :galleries do |galleries|
        galleries.resources :items
        galleries.resources :assets
      end
      admin.resources :galleries
    end
    map.connect 'gallery/:handle', :controller => 'galleries', :action => 'show'
    map.connect 'gallery/:gallery_handle/:handle', :controller => 'galleries/items', :action => 'show'
  end
  
  extension_config do |config|
    config.gem 'paperclip', :version => '~> 2.3.1.1', :source => 'http://gemcutter.org'
    config.gem 'acts_as_list', :source => 'http://gemcutter.org'
    #config.gem 'radiant-paperclipped-extension'
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
