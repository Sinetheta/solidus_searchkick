require 'spec_helper'

RSpec.describe Spree::ProductsController, type: :routing do
  describe 'routing' do
    routes { Spree::Core::Engine.routes }
    let(:taxon) { create(:taxon) }
  end
end
