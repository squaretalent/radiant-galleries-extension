var GalleriesList = {};
var AssetsList = {};

document.observe("dom:loaded", function() {
  gallery = new Gallery();
  gallery.ItemsDump();
  gallery.ItemsSort();
  
  Event.addBehavior({
    '#galleries .gallery:(#galleries_empty)' : GalleriesList.Events,
    '#assets_list .asset:not(#assets_empty)' : AssetsList.Events
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

var Gallery = Class.create({
  
  GallerySelect: function(element) {
    $('gallery_id').value = element.getAttribute('data-id');
    $('gallery_title').value = element.getAttribute('data-title');
    
    $('gallery_items_list').innerHTML = null;
    
    new Ajax.Request($('gallery_items_path').value + '?' + new Date().getTime(), {
      method: 'get',
      parameters: { 'id' : element.getAttribute('data-id')},
      onSuccess: function(data) {
        $('gallery_items_list').innerHTML = data.responseText;

        // response.each(function(item) {
        //   var element = document.createElement('li');
        //   var element_image = document.createElement('img');
        //   var element_span = document.createElement('span');
        //   
        //   element.id = 'gallery_item_id' + item.id;
        //   element.setAttribute('data-item_id', item.id);
        //   element.addClassName('gallery_item');
        //   
        //   element_image.setAttribute('src', item.title);
        //   
        //   element_span.addClassName('title');
        //   element_span.innerHTML = item.title;
        //   
        //   element.insert({
        //     'bottom' : element_image,
        //     'bottom' : element_span
        //   });
        //   
        //   $('gallery_items_list').insert({ 
        //     'bottom' : element
        //   });
        // })
      }
    });
    
    gallery.ItemsSort();
  },
  
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
        new Ajax.Request($('remove_gallery_item_path').value + '.json?' + new Date().getTime(), {
          method: 'get', // TODO this will be a delete
          parameters: {'id':element.getAttribute('data-item_id')},
          onSuccess: function(data) {
            this.response = data.responseText.evalJSON();
            
            $('assets_list').insert({'bottom': element});
            element.removeClassName('gallery_item').addClassName('asset');
            element.setAttribute('data-asset_id', this.response.id);
            element.id = "asset_" + this.response.id;
            
            AssetsList.Events.attach(element);
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
  }
  
});