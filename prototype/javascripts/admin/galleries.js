var Gallery = {};
var GalleryItem = {};
var GalleryAsset = {};

GalleryAsset.MakeDraggables = function () { 
  $$('#assets_list li.asset').each(function(element){
    new Draggable(element, { 
      revert: true
    });
  });
}

GalleryItem.MakeDraggables = function () { 
  $$('#gallery_items_list li.gallery_item').each(function(element){
    new Draggable(element, { 
      revert: false 
    });
    element.addClassName('move');
  });
}

Gallery.MakeDroppables = function () {
  Droppables.add($('gallery_items_list'), {
    accept: ['gallery_item', 'asset'],
    onDrop: function(element) {
      this.element.insert({ 'bottom': element.removeClassName('asset').addClassName('gallery_item').writeAttribute({'style':''}) });
    }
  });
}

document.observe("dom:loaded", function() {
  GalleryItem.MakeDraggables();
  Gallery.MakeDroppables();
  GalleryAsset.MakeDraggables();
});