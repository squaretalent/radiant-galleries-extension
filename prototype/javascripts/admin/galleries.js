var GalleryAsset = {};

document.observe("dom:loaded", function() {
  gallery = new Gallery();
  gallery.ItemRemove();
  gallery.ItemsSort();
  
  Event.addBehavior({
    '#assets_list .asset:not(#assets_empty)' : GalleryAsset.SendItem
  });
});

GalleryAsset.SendItem = Behavior.create({
  
  onclick: function() { 
    gallery.ItemAdd(this.element);
  }
  
});

var Gallery = Class.create({
  
  ItemAdd: function(element) {
    new Ajax.Request($('create_gallery_item_path').value + '.json?' + new Date().getTime(), { 
      method: 'get', //TODO this will be a put
      parameters: {'id' : element.getAttribute('data-asset_id')},
      onSuccess: function(data) {
        var response = data.responseText.evalJSON();
        
        element.id = "gallery_item_" + response.id;
        
        element.setAttribute('data-item_id', response.id);
        
        $('gallery_items_list').insert({ 'bottom' : element.removeClassName('asset').addClassName('gallery_item')});
        gallery.ItemsSort();
        Event.stopObserving(element, 'click');
        
      }.bind(this)
    });
  },
  
  ItemRemove: function(element) {
    Droppables.add($('gallery_items_remove'), {
      accept: ['gallery_item'],
      containment: ['gallery_items_list', 'gallery_items_remove'],
      onHover: function() {
        this.element.addClassName('over');
      },
      onDrop: function(element) {
        new Ajax.Request($('remove_gallery_item_path').value + '.json?' + new Date().getTime(), {
          method: 'get', // TODO this will be a delete
          parameters: {'id':element.getAttribute('data-item_id')},
          onSuccess: function(data) {
            this.response = data.responseText.evalJSON();
            
            $('assets_list').insert({'bottom': element});
            element.removeClassName('gallery_item').addClassName('asset');
            element.setAttribute('data-asset_id', this.response.id);
            element.id = "asset_" + this.response.id;
            
            GalleryAsset.SendItem.attach(element);
          }
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
        gallery.PositionItems();
      }
    });
  },
  
  PositionItems: function() {
    new Ajax.Request($('reorder_gallery_item_path').value + '.json?' + new Date().getTime(), {
      method: 'get', // TODO this will be a put
      parameters: {'items':Sortable.serialize('gallery_items_list')},
      onSuccess: function(data) {
        //this.response = data.responseText.evalJSON();
        $('gallery_items_remove').removeClassName('over');
      }
    });
  }
});