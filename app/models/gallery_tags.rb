module GalleryTags
  include Radiant::Taggable
  
  class GalleryTagError < StandardError; end
  
  tag 'galleries' do |tag|
    tag.expand
  end
  
  tag 'galleries:each' do |tag|
    Galleries.each do |gallery|
      tag.locals.gallery = gallery
      content << tag.expand
    end
    content
  end
  
  desc %{
    Select gallery based on id, handle or name
    <pre><code><r:gallery [id='id'] [handle='handle'] [name='name']>...</r:gallery></code></pre>
  }
  tag 'gallery' do |tag|
    tag.locals.gallery = find_gallery(tag)
    tag.expand unless tag.locals.gallery.nil?
  end
  
  [:title, :caption, :handle, :slug].each do |symbol|
    tag "gallery:#{symbol}" do |tag|
      tag.locals.item.title unless tag.locals.item.nil?
    end
  end
  
  tag 'gallery:if_items' do |tag|
    gallery = find_gallery(tag)
    tag.expand if gallery && !gallery.items.empty?
  end
  
  tag 'gallery:unless_items' do |tag|
    gallery = find_gallery(tag)
    tag.expand if !gallery || gallery.items.empty?
  end

protected
  
  def find_gallery(tag)
    if tag.locals.gallery
      tag.locals.gallery
    elsif tag.attr['id']
      Gallery.find(tag.attr['id'])
    elsif tag.attr['handle']
      Gallery.find(:handle, :conditions => {:handle => tag.attr['handle']})
    elsif tag.attr['title']
      Gallery.find(:first, :conditions => {:title => tag.attr['title']})
    end
  end