Spree::Product.class_eval do
  searchkick autocomplete: [:name]

  def search_data
    json = {
      name: name,
      description: description,
      active: available?,
      price: price,
      currency: cost_currency,
      conversions: orders.complete.count,
      taxon_ids: taxon_and_ancestors.map(&:id),
      taxon_names: taxon_and_ancestors.map(&:name)
    }

    Spree::Property.all.each do |prop|
      json.merge!(Hash[prop.name.downcase, property(prop.name)])
    end

    Spree::Taxonomy.all.each do |taxonomy|
      json.merge!(Hash["#{ taxonomy.name.downcase }_ids", taxon_by_taxonomy(taxonomy.id).map(&:id)])
    end

    json
  end

  def taxon_by_taxonomy(taxonomy_id)
    taxons.joins(:taxonomy).where(spree_taxonomies: { id: taxonomy_id })
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
