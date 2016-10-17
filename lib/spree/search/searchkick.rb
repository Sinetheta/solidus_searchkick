module Spree::Search
  class Searchkick < Spree::Core::Search::Base
    def retrieve_products
      @products = get_base_search
    end

    protected

    def get_base_search
      current_page = page || 1

      Spree::Product.search(
        keyword_query,
        where: where_query,
        aggs: aggregations,
        smart_aggs: true,
        order: order_query,
        limit: limit_query,
        offest: offset_query,
        page: current_page,
        per_page: per_page,
        includes: includes_query
      )
    end

    def where_query
      where_query = {
        active: true,
        currency: pricing_options.currency,
        price: { not: nil }
      }
      where_query.merge!({taxon_ids: taxon.id}) if taxon
      add_search_filters(where_query)
    end

    def keyword_query
      (keywords.nil? || keywords.empty?) ? "*" : keywords
    end

    def order_query
      order ? order : nil
    end

    def aggregations
      fs = []
      Spree::Taxonomy.filterable.each do |taxonomy|
        fs << taxonomy.filter_name.to_sym
      end
      Spree::Property.filterable.each do |property|
        fs << property.filter_name.to_sym
      end
      fs
    end

    def add_search_filters(query)
      return query unless search
      search.each do |name, scope_attribute|
        query.merge!(Hash[name, scope_attribute])
      end

      query
    end

    def includes_query
      includes =  { master: [:currently_valid_prices] }
      includes[:master] << :images if include_images
      includes
    end

    def limit_query
      limit ? limit : nil
    end

    def prepare(params)
      @properties[:order] = params[:order].blank? ? nil : params[:order]
      @properties[:limit] = params[:limit].blank? ? nil : params[:limit]
      params = params.deep_symbolize_keys
      super
    end
  end
end
