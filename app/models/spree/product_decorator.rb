Spree::Product.class_eval do
  # Run after initialization, allows us to process product_decorator from application before this
  Rails.application.config.after_initialize do
    # Check if searchkick_options have been set by the application using this gem
    # If they have, then do not initialize searchkick on the model. If they have not, then set the defaults
    searchkick autocomplete: [:name] unless Spree::Product.try(:searchkick_options)
  end

  def search_data
    json = {
      name: name,
      description: description,
      active: available?,
      price: price,
      currency: cost_currency,
      sku: sku,
      conversions: orders.complete.count,
      taxon_ids: taxon_and_ancestors.map(&:id),
      taxon_names: taxon_and_ancestors.map(&:name)
    }

    json
  end

  def taxon_and_ancestors
    taxons.map(&:self_and_ancestors).flatten.uniq
  end

  def self.autocomplete(keywords)
    if keywords
      Spree::Product.search(
        keywords,
        autocomplete: true,
        limit: 10, where: search_where
      ).map(&:name).map(&:strip).uniq
    else
      Spree::Product.search(
        '*',
        where: search_where
      ).map(&:name).map(&:strip)
    end
  end

  def self.search_where
    {
      active: true,
      price: { not: nil }
    }
  end
end
