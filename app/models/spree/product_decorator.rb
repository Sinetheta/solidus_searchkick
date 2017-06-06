Spree::Product.class_eval do
  searchkick SolidusSearchkick::Config.product_searchkick_options

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
        fields: ['name^5'],
        match: :word_start,
        limit: 10,
        load: false,
        misspellings: { below: 3 },
        where: search_where,
      ).map(&:name).map(&:strip).uniq
    else
      Spree::Product.search(
        '*',
        where: search_where
      ).map(&:name).map(&:strip).uniq
    end
  end

  def self.search_where
    {
      active: true,
      price: { not: nil }
    }
  end
end
