module SolidusSearchkick
  module Config
    # Options hash used when initializing searchkick on Spree::Product
    mattr_accessor(:product_searchkick_options) do
      {
        word_start: [:name]
      }
    end
  end
end
