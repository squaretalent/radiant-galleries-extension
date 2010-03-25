var Galleries = {};
var Assets = {};

document.observe("dom:loaded", function() {

  gallery = new Gallery();
  gallery.GalleryClear(); // Remove any stray data
  gallery.GallerySelect($('gallery_create')); // By default create gallery
  
  Event.addBehavior({    
    '#galleries .gallery:not(#galleries_empty)' : Galleries.List,
    '#galleries .gallery:not(#galleries_empty) .delete' : Galleries.Destroy,
    '#gallery_items_list .gallery_item .delete' : Galleries.ItemDelete,
    
    '#assets_list .asset:not(#assets_empty)' : Assets.List,
    '#asset_create-popup_close' : Assets.PopupClose,
    '#asset_form' : Assets.Form
  });
  
});

Galleries.List = Behavior.create({
  
  onclick: function() {
    gallery.GalleryClear();
    gallery.GallerySelect(this.element);
  }
  
});

Galleries.Destroy = Behavior.create({
  
  onclick: function() {
    if(confirm("Really Delete Gallery?")) {
      gallery.GalleryDestroy(this.element.up('.gallery'));
      shop.CategorySelect($('gallery_create'));
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

Assets.Form = Behavior.create({
  
  onsubmit: function() {
    gallery.AssetSubmit();
  }
  
});

Assets.PopupClose = Behavior.create({
  
  onclick: function() { 
    gallery.AssetClear();
  }
  
});

var Gallery = Class.create({
  
  GallerySelect: function(element) {
    // Select Element, Remove Ability to select it again
    this.GalleryClear();
    
    element.addClassName('current');
    element.stopObserving('click');

    $('gallery_items_list').innerHTML = '';
    $('assets_list').innerHTML = '';
    
    if(element.getAttribute('data-id') == '') {
      // Prepare Gallery Create UI
      $('gallery_items_alt').show();
      $('gallery_items').hide();
      $('gallery_items_alt').show();
      $('asset_create').hide();
      $('assets_list_alt').show();

      // Set Form to Create
      $('gallery_submit').value = 'Create';
      $('gallery_method').value = 'post';
      $('gallery_form').setAttribute('action', urlify($('galleries_path').value));
    } else {
      showStatus("Loading the items...");
            
      $('asset_create').show();
      new Ajax.Request(urlify($('galleries_path').value,element.getAttribute('data-id')), {
        method: 'get',
        onSuccess: function(data) {
          
          // Add items to gallery and activate sort
          $('gallery').innerHTML = data.responseText;
          gallery.ItemsSort();
          
          $('gallery_items_alt').hide();
          $('assets_list_alt').hide();
          
          this.AssetsList($('galleries_list').down('.current'));
        }.bind(this)
      });
    }
  },
  
  GalleryCreate: function() {
    $('galleries_list').insert({'top': this.response});
    
    var element = $('galleries_list').down();
    
    Galleries.List.attach(element);
    this.GallerySelect(element);
  },
  
  GalleryUpdate: function() {
    var element = $('galleries_list').down('.current');
    
    // This replaces the current item with the returned html
    element = element.replace(this.response); 
    
    // element is still the old item, but the id is the same as the new, so call on that id
    $(element.id).addClassName('current');
    $(element.id).stopObserving('click');
  },
  
  GalleryDestroy: function(element) {
    showStatus('Deleting Gallery...');
    element.hide();
    new Ajax.Request(urlify($('galleries_path').value, element.readAttribute('data-id')), { 
      method: 'delete',
      onSuccess: function(data) {
        element.remove();
        hideStatus();
      }.bind(this),
      onFailure: function(data) {
        element.show();
        alert(data.responseText);
        hideStatus();
      }.bind(this)
    });
  },
  
  GalleryClear: function() {
    // Reset Gallery Links
    $$('#galleries .gallery.current').each(function(element) { 
      element.removeClassName('current'); 
      Galleries.List.attach(element); 
    });
    
    $$('#gallery .clearable').each(function(input) {
      input.value = '';
    });
    
    // Remove Assets
    $('asset_create').hide();
    $('assets_list').inner_html = '';
  },
  
  ItemAdd: function(element) {
    element.hide();
    new Ajax.Request(urlify($('galleries_path').value,$('gallery_id').value + '/items'), {
      method: 'post',
      parameters: {
        'gallery_item[asset_id]' : element.getAttribute('data-asset_id')
      },
      onSuccess: function(data) {
        // Insert item into list, re-call events
        $('gallery_items_list').insert({ 'bottom' : data.responseText});
        gallery.ItemsSort();
        
        element.remove();
      }.bind(element),
      onFailure: function() {
        element.show();
      }
    });
  },
  
  ItemDelete: function(element) {
    element.hide();    
    new Ajax.Request(urlify($('gallery_items_path').value,element.getAttribute('data-item_id')), {
      method: 'delete',
      onSuccess: function(data) {
        this.response = data.responseText.evalJSON();
        
        // Turn item into Asset
        element.removeClassName('gallery_item').addClassName('asset');
        element.setAttribute('data-asset_id', this.response.id);
        element.id = "asset_" + this.response.id;
        
        // Add asset into list, recall events
        $('assets_list').insert({'top': element});
        element.show();
        gallery.AssetsLatestBind();
        
      }.bind(element),
      onFailure: function() {
        element.show();
      }
    });
  },
  
  ItemsSort: function() {
    Sortable.create('gallery_items_list', {
      constraint: false, 
      overlap: 'horizontal',
      containment: ['gallery_items_list'],
      onUpdate: function(element) {
        new Ajax.Request(urlify($('galleries_path').value + '/reorder',$('gallery_id').value), {
          method: 'put',
          parameters: {
            'id': $('gallery_id').value,
            'items':Sortable.serialize('gallery_items_list')
          },
          onSuccess: function(data) {
            // TODO Not really necessary, maybe failure
          }
        });
      }
    });
  },
  
  AssetsList: function(element) {  
    showStatus('and now the assets...');  
    new Ajax.Request(urlify($('gallery_assets_path').value), {
      method: 'get',
      parameters: { 
        'filter[image]' : 1,
        'gallery_id' : element.getAttribute('data-id')
      },
      onSuccess: function(data) {   
        setStatus('All Done');     
        $('assets_list').innerHTML = data.responseText;
        hideStatus();
      }
    });
  },
  
  AssetSubmit: function() {
    showStatus('Saving...');
  },
  
  AssetCreate: function() {
    Assets.List.attach($("assets_list").down(".asset"));
    this.AssetClear();
    
    hideStatus();
    
    return null;
  },
  
  AssetClear: function() {
    Element.closePopup('asset_create-popup');
    
    $$('#asset_form .clearable').each(function(input) {
      input.value = '';
    });
  }
  
});

function urlify(route, id) {
  var url = route;
  if ( id !== undefined ) {
    url += '/' + id
  }
  
  url += '.js?' + new Date().getTime();
  
  return url;
}