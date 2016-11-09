module Spree
  module Core
    # THIS FILE SHOULD BE OVER-RIDDEN IN YOUR SITE EXTENSION!
    #   the exact code probably won't be useful, though you're welcome to modify and reuse
    #   the current contents are mainly for testing and documentation

    # To override this file...
    #   1) Make a copy of it in your sites local /lib/spree folder/core
    #   2) Add it to the config load path, or require it in an initializer, e.g...
    #
    #      # config/initializers/spree.rb
    #      require 'spree/core/searchkick_filters'
    #

    module SearchkickFilters
      def self.all_filters
        filters = []
        # Find all methods that ends with '_filter'
        filter_methods = Spree::Core::SearchkickFilters.methods.find_all { |m| m.to_s.end_with?('_filter') }
        filter_methods.each do |filter_method|
          filters << Spree::Core::SearchkickFilters.send(filter_method) if Spree::Core::SearchkickFilters.respond_to?(filter_method)
        end
        filters
      end

      def self.price_filter
        conds = [
          [Spree.t(:under_price, price: format_price(1)),   { range: { price: { lt: 1 } } }],
          ["#{format_price(1)} - #{format_price(5)}",       { range: { price: { from: 1, to: 5 } } }],
          ["#{format_price(5)} - #{format_price(10)}",      { range: { price: { from: 5, to: 10 } } }],
          ["#{format_price(10)} - #{format_price(15)}",     { range: { price: { from: 10, to: 15 } } }],
          ["#{format_price(15)} - #{format_price(25)}",     { range: { price: { from: 15, to: 25 } } }],
          ["#{format_price(25)} - #{format_price(50)}",     { range: { price: { from: 25, to: 50 } } }],
          ["#{format_price(50)} - #{format_price(100)}",    { range: { price: { from: 50, to: 100 } } }],
          [Spree.t(:over_price, price: format_price(100)),  { range: { price: { gt: 100 } } }]
        ]
        {
          name:   'Price',
          scope:  :price,
          conds:  Hash[*conds.flatten],
          labels: conds.map { |k, _v| [k, k] }
        }
      end

      def self.format_price(amount)
        Spree::Money.new(amount)
      end
    end
  end
end
