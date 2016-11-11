module SolidusSearchkick
  class Railtie < Rails::Railtie
    initializer "solidus_searchkick.add_helpers" do
      ActionView::Base.send :include, SolidusSearchkick::Helpers::FormHelper
    end
  end
end
