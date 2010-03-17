module GalleryItemTags
  include Radiant::Taggable
  
  class GalleryTagError < StandardError; end
  
  tag 'gallery:items' do |tag|
    tag.expand
  end
  
  tag 'gallery:items:size' do |tag|
    gallery = GalleryTags.find_gallery(tag)
    gallery.items.size
  end
  
  tag 'gallery:items:each' do |tag|
    gallery = GalleryTags.find_gallery(tag)
    unless gallery.nil?
      gallery.items.each do |item|
        tag.locals.item = item
        content << tag.expand
      end
      content
    end
  end
  
  
  desc %{
    Select gallery item based on id, handle, name or position
    <pre><code><r:gallery>
      <r:item [id='id'] [handle='handle'] [name='name'] [position='position']>...</r:item>
    </r:gallery></code></pre>
  }
  tag 'gallery:item' do |tag|     
    tag.locals.item = find_item(tag)    
    tag.expand  
  end
  
  [:title, :caption, :handle, :slug].each do |symbol|
    tag "gallery:item:#{symbol}" do |tag|
      tag.locals.item.title unless tag.locals.item.nil?
    end
  end
  
  desc %{
    Return the url for the image, specify style if wanting thumb etc
    <pre><code><r:gallery:item:image [style='thumbnail']>
  }
  tag 'gallery:item:image' do |tag|
    if tag.attr['style'].nil?
      style = 'original'
    else
      style = tag.attr['style']
    tag.locals.item.image(style.to_sym) unless tag.locals.item.nil?
  end
  
protected

  def find_item(tag)
    if tag.locals.item
      tag.locals.item
    elsif tag.attr['id']
      GalleryItem.find(tag.attr['id'])
    elsif tag.attr['handle']
      GalleryItem.find(:first, :conditions => {:handle => tag.attr['handle'])
    elsif tag.attr['title']
      GalleryItem.find(:first, :conditions => {:title => tag.attr['title']})
    elsif tag.attr['position']
      GalleryItem.find(:first, :conditions => {:position => tag.attr['position']})
    end
  end

end