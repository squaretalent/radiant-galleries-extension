module GalleriesAdminUI

 def self.included(base)
   base.class_eval do
    
    attr_accessor :galleries
    
    protected
      
      def load_default_galleries_regions
        returning OpenStruct.new do |galleries|
          galleries.edit = Radiant::AdminUI::RegionSet.new do |edit|
            edit.main.concat %w{edit_header edit_form edit_popups}
            edit.sidebar
            edit.form.concat %w{edit_title edit_extended_metadata edit_content}
            edit.form_bottom.concat %w{edit_buttons edit_timestamp}
          end
          galleries.new = galleries.edit
          galleries.index = Radiant::AdminUI::RegionSet.new do |index|
            index.top
            index.bottom.concat %w{ add_gallery }
            index.thead.concat %w{ title_header description_header modify_header }
            index.tbody.concat %w{ thumbnail_cell title_cell description_cell remove_cell }
          end
          galleries.remove = galleries.index
        end
      end
       
    end
  end
end

