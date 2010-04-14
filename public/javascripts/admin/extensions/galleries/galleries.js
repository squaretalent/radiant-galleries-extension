var GalleryAssets = {};

document.observe("dom:loaded", function() {
  gallery = new Gallery();
  gallery.Initialize();
  
  Event.addBehavior({
    '#asset_popup_close:click' : function(e) { gallery.AssetClear(); },
    '#asset_form:submit' : function(e) { gallery.AssetSubmit(); },
    
    '#assets_list .asset:click' : function(e) { gallery.ItemCreate($(this)); },
    '#items_list .item .actions .delete:click' : function(e) { gallery.ItemDestroy($(this).up('.item'))}
  });
});

GalleryAssets.List = Behavior.create({
  
  onclick: function() { 
    gallery.ItemCreate(this.element);
  }
  
});

var Gallery = Class.create({
  
  Initialize: function() {
    if($('gallery_id')) {
      this.ItemsSort();
    }
  },
  
  ItemsSort: function() {
    Sortable.create('items_list', {
      constraint: false, 
      overlap: 'horizontal',
      containment: ['items_list'],
      onUpdate: function(element) {
        new Ajax.Request(urlify($('admin_gallery_items_sort_path').value), {
          method: 'put',
          parameters: {
            'gallery_id': $('gallery_id').value,
            'items':Sortable.serialize('items_list')
          }
        });
      }.bind(this)
    });
  },
  
  ItemCreate: function(element) {
    showStatus('Adding Item...');
    element.hide();
    new Ajax.Request(urlify($('admin_gallery_items_path').value), {
      method: 'post',
      parameters: {
        'gallery_id' : $('gallery_id').value,
        'gallery_item[asset_id]' : element.getAttribute('data-id')
      },
      onSuccess: function(data) {
        // Insert item into list, re-call events
        $('items_list').insert({ 'bottom' : data.responseText});
        gallery.ItemsSort();
        
        element.remove();
        hideStatus();
      }.bind(element),
      onFailure: function() {
        element.show();
        hideStatus();
      }
    });
  },
  
  ItemDestroy: function(element) {
    showStatus('Deleting Item...');
    element.hide();
    new Ajax.Request(urlify($('admin_gallery_items_path').value, element.readAttribute('data-id')), { 
      method: 'delete',
      onSuccess: function(data) {
        $('assets_list').insert({ 'bottom' : data.responseText });
        element.remove();
        hideStatus();
      }.bind(this),
      onFailure: function(data) {
        element.show();
        hideStatus();
      }.bind(this)
    });
  },
  
  AssetSubmit: function() {
    showStatus('Uploading Item...');
  },
  
  AssetCreate: function() {
    GalleryAssets.List.attach($("assets_list").down(".asset"));
    this.ItemCreate($("assets_list").down(".asset"));
    this.AssetClear();
    
    hideStatus();
    
    return null;
  },
  
  AssetClear: function() {
    Element.closePopup('asset_popup');
    
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