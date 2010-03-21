document.observe("dom:loaded", function() {
  gallery = new Gallery();
  gallery.AssetsDrop();
  gallery.ItemRemove();
  gallery.ItemsSort();
  
  galleryAsset = new GalleryAsset();
  galleryAsset.MakeDraggables();
});

var GalleryAsset = Class.create({
  MakeDraggables: function() { 
    $$('#assets_list li.asset').each(function(element){
      new Draggable(element, { 
        revert: true
      });
    });
  }
});

var Gallery = Class.create({
  AssetsDrop: function() {
    Droppables.add($('gallery_items_list'), {
      accept: ['asset'],
      onHover: function(element) {
        this.element.insert({ 'bottom': element.removeClassName('asset').addClassName('gallery_item')});
      
        new Ajax.Request('/admin/galleries/items/create.json?' + new Date().getTime(), { 
          method: 'get', //TODO this will be a put
          parameters: {'id':element.getAttribute('data-id')},
          onSuccess: function(data) {
            this.response = data.responseText.evalJSON();
            element.id = "gallery_item_" + this.response.id;
          }
        });
      }
    });
  },
  
  ItemRemove: function() {
    Droppables.add($('gallery_items_remove'), {
      accept: ['gallery_item'],
      containment: ['gallery_items_list', 'gallery_items_remove'],
      onHover: function(element) {
        this.element.addClassName('over');
      },
      onDrop: function(element) {
        new Ajax.Request('/admin/galleries/items/delete.json?' + new Date().getTime(), { 
          method: 'get', //TODO this will be a delete
          parameters: {'id':element.getAttribute('data-id')},
          onSuccess: function(data) {
            this.response = data.responseText.evalJSON();

            $('assets_list').insert({'bottom': element});
            element.removeClassName('gallery_item').addClassName('asset');
            element.setAttribute('data-id', this.response.id);
            element.id = "asset_" + this.response.id;
          }
        });
        this.element.removeClassName('over');
      }
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
    new Ajax.Request('/admin/galleries/items/reorder.json?' + new Date().getTime(), { 
      method: 'get', //TODO this will be a put
      parameters: {'items':Sortable.serialize('gallery_items_list')},
      onSuccess: function(data) {
        //this.response = data.responseText.evalJSON();
        $('gallery_items_remove').removeClassName('over');
      }
    });
  }
});