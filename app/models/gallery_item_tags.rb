module GalleryItemTags
  include Radiant::Taggable
  
  class GalleryTagError < StandardError; end
  
  tag 'gallery:items' do |tag|
    tag.expand
  end
  
  tag 'gallery:items:size' do |tag|
    gallery = find_gallery(tag)
    gallery.items.size
  end
  
  tag 'gallery:items:each' do |tag|
    content = ''
    gallery = find_gallery(tag)
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
    <pre><code><r:gallery:item [id='id'] [handle='handle'] [name='name'] [position='position']>...</r:gallery:item></code></pre>
  }
  tag 'gallery:item' do |tag|
    tag.locals.item = find_gallery_item(tag)
    tag.expand unless tag.locals.item.nil?
  end
  
  [:title, :caption, :handle].each do |symbol|
    tag "gallery:item:#{symbol}" do |tag|
      unless tag.locals.item.nil?
        hash = tag.locals.item
        hash[symbol]
      end
    end
  end
  
  tag 'gallery:item:slug' do |tag|
    tag.locals.item.slug unless tag.locals.item.nil?
  end
  
  desc %{
    Return the url for the image, specify style if wanting thumb etc
    <pre><code><r:gallery:item:image [style='thumbnail']></code></pre>
  }
  tag 'gallery:item:image' do |tag|
    if tag.attr['style'].nil?
      style = 'original'
    else
      style = tag.attr['style']
    end
    tag.locals.item.image.thumbnail(style.to_sym) unless tag.locals.item.nil?
  end

  tag 'pagey' do |tag|
    tag.locals.item = find_gallery_item(tag)
    tag.locals.item.inspect
  end
  
protected

  def find_gallery_item(tag)
    if tag.locals.item
      tag.locals.item
    elsif tag.attr['id']
      GalleryItem.find(tag.attr['id'])
    elsif tag.attr['handle']
      GalleryItem.find(:first, :conditions => {:handle => tag.attr['handle']})
    elsif tag.attr['title']
      GalleryItem.find(:first, :conditions => {:title => tag.attr['title']})
    elsif tag.attr['position']
      GalleryItem.find(:first, :conditions => {:position => tag.attr['position']})
    else
      GalleryItem.find(:first, :conditions => {:handle => tag.locals.page.slug})
    end
  end

end