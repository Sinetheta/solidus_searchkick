require 'spec_helper'

RSpec.describe Spree::ProductsHelper do
  include ActiveSupport::Testing::TimeHelpers

  describe 'cache_key_for_products' do
    helper do
      # Normally provided by Spree::Core::ControllerHelpers::Pricing
      def current_pricing_options
        Spree::Config.pricing_options_class.new(currency: 'USD')
      end

      # Normally provided by Spree::Core::ControllerHelpers::Search
      def build_searcher(params)
        Spree::Config.searcher_class.new(params).tap do |searcher|
          searcher.current_user = FactoryGirl.create(:user)
          searcher.pricing_options = current_pricing_options
        end
      end
    end

    # Performed in controller before cache key is used
    def load_products
      products
      Spree::Product.reindex
      searcher = helper.build_searcher(params)
      @products = searcher.retrieve_products
    end

    let(:products) do
      travel_to(Time.local(1990)) do
        create_list(:product, 2)
      end
    end
    let(:params) { {} }

    subject { helper.cache_key_for_products }

    after do
      # Since we're using timecop we need to avoid index collisions
      Spree::Product.searchkick_index.delete
    end

    it 'returns a long string' do
      load_products
      is_expected.to eq('en/USD/spree/products/all--bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f-19900101000000-2')
    end

    context 'when products are updated' do
      before do
        load_products
        products.first.update(updated_at: Time.local(1992))
      end

      it { is_expected.to eq('en/USD/spree/products/all--bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f-19920101000000-2') }
    end

    context 'when no products are found' do
      let(:products) { nil }

      it 'uses the current time ' do
        travel_to(Time.local(1991)) do
          load_products
          expect(subject).to eq('en/USD/spree/products/all--bf21a9e8fbc5a3846fb05b4fa0859e0917b2202f-19910101-0')
        end
      end
    end
  end
end
