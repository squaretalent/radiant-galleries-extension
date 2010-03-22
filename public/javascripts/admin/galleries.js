var GalleriesList = {};
var AssetsList = {};
var AssetFormClose = {};

document.observe("dom:loaded", function() {

  gallery = new Gallery();
  gallery.GalleryClear();
  gallery.ItemsDump();
  gallery.ItemsSort();
  
  Event.addBehavior({
    '#galleries .gallery:(#galleries_empty)' : GalleriesList.Events,
    '#assets_list .asset:not(#assets_empty)' : AssetsList.Events,
    '#asset_create-popup_close' : AssetFormClose.Events
  });
  
});

GalleriesList.Events = Behavior.create({
  
  onclick: function() {
    gallery.GallerySelect(this.element);
  }
  
});

AssetsList.Events = Behavior.create({
  
  onclick: function() { 
    gallery.ItemAdd(this.element);
  }
  
});

AssetFormClose.Events = Behavior.create({
  
  onclick: function() { 
    gallery.AssetFormClear();
  }
  
});

var Gallery = Class.create({
  
  GalleryClear: function() {
    $('gallery_id').value = null;
    $('gallery_title').value = null;
    $('gallery_items').hide();
    $('gallery_items_alt').show();
    
    $('asset_create').hide();
    $('asset_asset').value = null;
    
    $$('.gallery.current').each(function(element) { 
      element.removeClassName('current'); 
      GalleriesList.Events.attach(element); 
    });
  },
  
  GallerySelect: function(element) {
    gallery.GalleryClear();
    gallery.AssetsList(element);
    element.addClassName('current');
    element.stopObserving('click');
    
    if(element.getAttribute('data-id') == '') {
      // New Gallery
    } else {      
      $('gallery_id').value = element.getAttribute('data-id');
      $('gallery_title').value = element.getAttribute('data-title');

      $('gallery_items_list').innerHTML = null;

      new Ajax.Request($('gallery_items_path').value + '?' + new Date().getTime(), {
        method: 'get',
        parameters: { 
          'gallery_id' : element.getAttribute('data-id')
        },
        onSuccess: function(data) {
          $('gallery_items').show();
          $('gallery_items_alt').hide();

          $('gallery_items_list').innerHTML = data.responseText;
          gallery.ItemsSort();
        }
      });
    }
    
  },
  
  ItemAdd: function(element) {
    new Ajax.Request($('gallery_items_path').value + '/create.json?' + new Date().getTime(), {
      method: 'post',
      parameters: {
        'gallery_id' : $('gallery_id').value,
        'item[asset_id]' : element.getAttribute('data-asset_id')
      },
      onSuccess: function(data) {
        var response = data.responseText.evalJSON();
        
        element.id = "gallery_item_" + response.id;
        
        element.setAttribute('data-item_id', response.id);
        
        $('gallery_items_list').insert({ 'bottom' : element.removeClassName('asset').addClassName('gallery_item')});
        gallery.ItemsSort();
        element.stopObserving('click');
        
      }.bind(this)
    });
  },
  
  ItemsDump: function(element) {
    Droppables.add($('gallery_items_remove'), {
      accept: ['gallery_item'],
      containment: ['gallery_items_list', 'gallery_items_remove'],
      onHover: function() {
        this.element.addClassName('over');
      },
      onDrop: function(element) {
        new Ajax.Request($('gallery_items_path').value + '/' + element.getAttribute('data-item_id') + '/delete.json?' + new Date().getTime(), {
          method: 'delete',
          onSuccess: function(data) {
            this.response = data.responseText.evalJSON();
            
            $('assets_list').insert({'top': element});
            element.removeClassName('gallery_item').addClassName('asset');
            element.setAttribute('data-asset_id', this.response.id);
            element.id = "asset_" + this.response.id;
            
            gallery.AssetsLatestBind();
            
          }.bind(element)
        });
        this.element.removeClassName('over');
      }.bind(element)
    });
  },
  
  ItemsSort: function() {
    
    Sortable.create('gallery_items_list', {
      constraint: false, 
      containment: ['gallery_items_list', 'gallery_items_remove'],
      onChange: function(element) {
        $('gallery_items_remove').removeClassName('over');
      },
      onUpdate: function(element) {
        new Ajax.Request($('galleries_path').value + '/' + $('gallery_id').value  + '/reorder.json?' + new Date().getTime(), {
          method: 'put',
          parameters: {
            'id': $('gallery_id').value,
            'items':Sortable.serialize('gallery_items_list')
          },
          onSuccess: function(data) {
            //this.response = data.responseText.evalJSON();
          }
        });
      }
    });
  },
  
  AssetsList: function(element) {
    $('asset_create').show();
    new Ajax.Request($('gallery_assets_path').value + '?' + new Date().getTime(), {
      method: 'get',
      parameters: { 
        'filter[image]' : 1,
        'gallery_id' : element.getAttribute('data-id')
      },
      onSuccess: function(data) {
        $('assets_list').innerHTML = data.responseText;
      }
    });
  },
  
  AssetsLatestBind: function() {
    AssetsList.Events.attach($("assets_list").down(".asset"));
    
    return null;
  },
  
  AssetFormClear: function() {
    Element.closePopup('asset_create-popup');
    $('asset_asset').value = null;
  }
  
});