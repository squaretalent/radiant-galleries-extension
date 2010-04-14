require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/galleries_extensions"
require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/page_extensions_for_gallery"

require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/gallery_page_extensions"
require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/galleries_admin_ui"

require_dependency "#{File.expand_path(File.dirname(__FILE__))}/lib/asset_gallery_item_associations"

include Admin::GalleriesHelper

class GalleriesExtension < Radiant::Extension
  version "1.0.1"
  description "Photo Galleries using the paperclipped extension for assets"
  url "http://github.com/squaretalent/radiant-galleries-extension"

  define_routes do |map|
    map.namespace :admin, :member => {:remove => :get} do |admin|

      admin.namespace :galleries do |galleries|
        galleries.resources :assets, :controller => 'assets', :only => [ :index, :show, :create ]
        galleries.sort 'sort.:format', :action => 'sort', :conditions => { :method => :put }
      end
      admin.resources :galleries do |gallery|
        gallery.items_sort 'items/sort.:format', :controller => 'galleries/items', :action => 'sort', :conditions => { :method => :put }
        gallery.resources :items, :controller => 'galleries/items', :only => [ :index, :create, :show, :destroy ]
      end
    end
    map.connect 'news/galleries/:handle', :controller => 'galleries', :action => 'show'
    map.connect 'news/galleries/:gallery_handle/:handle', :controller => 'galleries/items', :action => 'show'
  end
  
  extension_config do |config|
    config.gem 'paperclip', :version => '~> 2.3.1.1', :source => 'http://gemcutter.org'
    config.gem 'acts_as_list', :source => 'http://gemcutter.org'
    #config.gem 'radiant-paperclipped-extension'
  end
  
  def activate    
    unless defined? admin.galleries
      Radiant::AdminUI.send :include, GalleriesAdminUI
      admin.galleries = Radiant::AdminUI.load_default_galleries_regions
    end
    
    Page.class_eval { include GalleryTags, GalleryItemTags, PageExtensionsForGallery }
    Asset.class_eval { include AssetGalleryItemAssociations }
    Admin::GalleriesController.send( :include, GalleriesExtensions )
    
    UserActionObserver.instance
    UserActionObserver.class_eval do
      observe Gallery, GalleryItem
    end
    
    tab 'Content' do
      add_item 'Galleries', '/admin/galleries', :after => 'Pages'
    end
    
    admin.page.edit.add :layout_row, 'gallery' if admin.respond_to?(:page)    
  end
end
