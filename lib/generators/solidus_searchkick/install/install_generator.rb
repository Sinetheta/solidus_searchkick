module SolidusSearchkick
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root SolidusSearchkick.root

      def add_templates
        copy_file "app/views/spree/shared/_filters.html.erb", "app/views/spree/shared/_filters.html.erb"
      end
    end
  end
end
