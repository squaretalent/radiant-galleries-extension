module GalleriesExtensions
  
  def self.included(base)
    base.class_eval {
      before_filter :initialize_meta_buttons_and_parts
      
      def initialize_meta_buttons_and_parts
        @meta ||= []
        @meta << {:field => "handle", :type => "text_field", :args => [{:class => 'textbox', :maxlength => 160}]}
        
        @buttons_partials ||= []
        
        @parts ||= []
        @parts << {:title => 'items'}
      end
    }
  end
  
end