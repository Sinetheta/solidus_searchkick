Spree::ProductsHelper.module_eval do
  def cache_key_for_products
    count = @products.count
    hash = Digest::SHA1.hexdigest(params.to_json)
    max_updated_at = (@products.records.maximum(:updated_at) || Date.today).to_s(:number)
    "#{I18n.locale}/#{current_pricing_options.cache_key}/spree/products/all-#{params[:page]}-#{hash}-#{max_updated_at}-#{count}"
  end
end
