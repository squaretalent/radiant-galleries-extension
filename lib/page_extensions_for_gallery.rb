module PageExtensionsForGallery
  class << self
    def included(base)
      base.belongs_to :gallery, :class_name => 'Gallery', :foreign_key => 'gallery_id'
    end
  end
end