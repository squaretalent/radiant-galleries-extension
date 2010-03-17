# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class GalleriesExtension < Radiant::Extension
  version "1.0"
  description "Photo Galleries using the paperclipped extension for assets"
  url "http://github.com/squaretalent/radiant-galleries-extension"

  define_routes do |map|
    map.namespace :admin, :member => {:remove => :get} do |admin|
      admin.resources :galleries
      admin.namespace :galleries, :as => :gallery do |gallery|
        gallery.resources :items
      end
    end
    map.connect 'gallery/:handle', :controller => 'galleries', :action => 'show'
    map.connect 'gallery/item/:handle', :controller => 'galleries/items', :action => 'show'
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
    GalleryPage.send(:include, GalleryTags, GalleryItemTags)
    
    tab 'Content' do
      add_item 'Galleries', '/admin/galleries', :after => 'Pages'
    end
    
    admin.page.edit.add :layout_row, 'gallery' if admin.respond_to?(:page)
  end
end
