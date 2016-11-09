require 'spec_helper'
describe Spree::Search::Searchkick do
  let(:product) { create(:product) }

  before do
    product.reindex
    Spree::Product.reindex
  end

  describe 'configure' do
    before do
      Spree::Search::Searchkick.configure do |config|
        config.configurable_attribute = true
      end
    end

    it "allows configurable_attribute to be configured" do
      expect(Spree::Search::Searchkick.configuration.configurable_attribute).to be_truthy
    end
  end

  describe "#retrieve_products" do
    it "returns matching products" do
      products = Spree::Search::Searchkick.new({}).retrieve_products
      expect(products.count).to eq 1
    end
  end
end
