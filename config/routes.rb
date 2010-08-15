ActionController::Routing::Routes.draw do |map|

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

