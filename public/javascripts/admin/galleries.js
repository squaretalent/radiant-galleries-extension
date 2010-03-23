var Galleries = {};
var Assets = {};

document.observe("dom:loaded", function() {

  gallery = new Gallery();
  gallery.GalleryClear();
  gallery.GallerySelect($('gallery_create'));
  gallery.ItemsSort();
  
  Event.addBehavior({
    '#assets_list .asset:not(#assets_empty)' : Assets.List,
    '#asset_create-popup_close' : Assets.PopupClose,
    
    '#galleries .gallery:not(#galleries_empty)' : Galleries.List,
    '#galleries .gallery:not(#galleries_empty) .delete' : Galleries.Delete,
    '#gallery_items_list .gallery_item .delete' : Galleries.ItemDelete
  });
  
});

Galleries.List = Behavior.create({
  
  onclick: function() {
    gallery.GalleryClear();
    gallery.GallerySelect(this.element);
  }
  
});

Galleries.Delete = Behavior.create({
  
  onclick: function() {
    if(confirm("Really Delete Category?")) {
      gallery.GalleryDelete(this.element.up('.gallery'));
    }
    
    return false;  
  }
  
});

Galleries.ItemDelete = Behavior.create({
  
  onclick: function() {
    gallery.ItemDelete(this.element.up('.gallery_item'));
  }
  
});

Assets.List = Behavior.create({
  
  onclick: function() { 
    gallery.ItemAdd(this.element);
  }
  
});

Assets.PopupClose = Behavior.create({
  
  onclick: function() { 
    gallery.AssetFormClear();
  }
  
});

var Gallery = Class.create({
  
  GalleryClear: function() {
    $('gallery_id').value = null;
    $('gallery_title').value = null;
    $('gallery_items').hide();
    
    $('asset_create').hide();
    $('asset_asset').value = null;
    
    $$('.gallery.current').each(function(element) { 
      element.removeClassName('current'); 
      Galleries.List.attach(element); 
    });
  },
  
  GallerySelect: function(element) {
    gallery.AssetsList(element);
    element.addClassName('current');
    element.stopObserving('click');
    
    if(element.getAttribute('data-id') == '') {
      $('gallery_items_alt').show();
      
      $('gallery_form').setAttribute('action', $('galleries_path').value + '.js');
      $('gallery_submit').value = 'Create';
      $('gallery_method').value = 'post';
    } else {
      $('gallery_form').setAttribute('action', $('galleries_path').value + '/' + element.getAttribute('data-id') + '.js');
      $('gallery_method').value = 'put';
      $('gallery_id').value     = element.getAttribute('data-id');
      $('gallery_title').value  = element.getAttribute('data-title');
      $('gallery_submit').value = 'Update';
      
      $('gallery_items_alt').hide();
      $('gallery_items_list').innerHTML = null;
      $('gallery_items').show().addClassName('pending');
      
      $('assets').addClassName('pending');
      $('asset_create').show();
      
      new Ajax.Request($('gallery_items_path').value + '?' + new Date().getTime(), {
        method: 'get',
        parameters: { 
          'gallery_id' : element.getAttribute('data-id')
        },
        onSuccess: function(data) {
          $('gallery_items_list').innerHTML = data.responseText;
          gallery.ItemsSort();
          
          $('gallery_items').removeClassName('pending');
          $('assets').removeClassName('pending');
        }
      });
    }
  },
  
  GalleryDelete: function(element) {
    gallery.GalleryClear();
    element.hide();
    new Ajax.Request($('galleries_path').value + '/' + element.getAttribute('data-id') + '/remove.js?' + new Date().getTime(), {
      method: 'get',
      onSuccess: function(data) {
        element.remove();
      }.bind(element),
      onFailure: function(data) {
        element.show();        
        gallery.GallerySelect(element);
      }
    });
  },
  
  GalleriesLatestBind: function() {
    var element = $('galleries_list').select(".gallery:last-child")[0];

    Galleries.List.attach(element);
    gallery.GallerySelect(element);
    
    return null;
  },
  
  GalleriesUpdate: function() {
    var element = $('galleries_list').down('.current');

    element.setAttribute('data-title', $('gallery_title').value);
    element.down('.title').innerHTML = $('gallery_title').value;
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
  
  ItemDelete: function(element) {
    element.hide();
    new Ajax.Request($('gallery_items_path').value + '/' + element.getAttribute('data-item_id') + '/remove.json?' + new Date().getTime(), {
      method: 'get',
      onSuccess: function(data) {
        this.response = data.responseText.evalJSON();
        
        $('assets_list').insert({'top': element});
        element.removeClassName('gallery_item').addClassName('asset');
        element.setAttribute('data-asset_id', this.response.id);
        element.id = "asset_" + this.response.id;
        element.show();
        
        gallery.AssetsLatestBind();
        
      }.bind(element)
    });
  },
  
  ItemsSort: function() {
    Sortable.create('gallery_items_list', {
      constraint: false, 
      overlap: 'horizontal',
      containment: ['gallery_items_list'],
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
    $('assets_list').innerHTML = null;
    $('assets_list').addClassName('pending');
    
    new Ajax.Request($('gallery_assets_path').value + '?' + new Date().getTime(), {
      method: 'get',
      parameters: { 
        'filter[image]' : 1,
        'gallery_id' : element.getAttribute('data-id')
      },
      onSuccess: function(data) {
        $('assets_list').innerHTML = data.responseText;
        $('assets_list').removeClassName('pending');
      }
    });
  },
  
  AssetsLatestBind: function() {
    Assets.List.attach($("assets_list").down(".asset"));
    
    return null;
  },
  
  AssetFormClear: function() {
    Element.closePopup('asset_create-popup');
    $('asset_title').value = null;
    $('asset_caption').value = null;
    $('asset_asset').value = null;

  }
  
});