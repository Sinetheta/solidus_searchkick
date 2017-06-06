[![Build Status](https://travis-ci.org/elevatorup/solidus_searchkick.svg?branch=master)](https://travis-ci.org/elevatorup/solidus_searchkick)
[![Code Climate](https://codeclimate.com/github/elevatorup/solidus_searchkick/badges/gpa.svg)](https://codeclimate.com/github/elevatorup/solidus_searchkick)
[![Test Coverage](https://codeclimate.com/github/elevatorup/solidus_searchkick/badges/coverage.svg)](https://codeclimate.com/github/elevatorup/solidus_searchkick/coverage)

Solidus + Searchkick
====================

Add [Elasticsearch](http://elastic.co) to Solidus, powered by [searchkick](http://searchkick.org).

Features
--------

* Search products by sku, name, description, taxon, and more out of the box.
* Customize the product search fields to your liking.
* Search Autocomplete by name out of the box ([Typeahead](https://twitter.github.io/typeahead.js/)).
* Product filtering based on ElasticSearch queries.

Installation
------------

Add searchkick and solidus_searchkick to your Gemfile:

```ruby
gem 'searchkick'
gem 'solidus_searchkick'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g solidus_searchkick:install
```

Installing solidus_searchkick will copy over a new `spree/shared/_filters.html.erb` template. This includes a few minor changes to the default template, mainly changing a few `search` params to `filter` params to work nicely with solidus_searchkick and elasticsearch.

[Install elasticsearch](https://www.elastic.co/downloads/elasticsearch)

Searchkick Integration
----------------------

By default, Searchkick is initialized on the Product model in SolidusSearchkick's `product_decorator` with:
```
searchkick word_start: [:name]
```

If you need to modify this, you can do so in an initializer

```
# config/initializers/searchkick.rb
SolidusSearchkick::Config.product_searchkick_options = {
  batch_size: 200,
  settings: {
    'index.mapping.total_fields.limit' => 3000,
    'index.mapping.ignore_malformed' => true
  },
  suggest: [:name],
  word_start: [:name]
}
```

Search Parameters
-----------------

By default, only the `Spree::Product` class is indexed. The following items are indexed by default:
* name
* description
* available? (indexed as `active`)
* price (needed in order to return products that have price != nil)
* currency
* sku
* orders.complete.count (indexed as `conversions`)
* taxon_ids
* taxon_names

In order to control what data is indexed, override the `Spree::Product#search_data` method. Call `Spree::Product.reindex` after changing this method.

Filtering
---------

Initially, you start with a very basic filtering system which includes a price filter in order to show how the filtering works with SolidusSearchkick and ElasticSearch. In order to add additional filters or change the price filter, the following steps will need to be taken:

1. Copy the `Spree::Core::SearchkickFilters` file from this gem and place it in `lib/spree/core/`

2. Add it to the config load path, or require it in an initializer, e.g...
   ```
   # config/initializers/spree.rb
   require 'spree/core/searchkick_filters'
   ```

3. Modify SearchkickFilters as needed.

The `conds` for `SearchkickFilters` are similar to the `ProductFilters` in the default version of spree/solidus. Although the first parameters of each is still the label, the second item is the ElasticSearch DSL that will be used for that filter, eg...

  ```
  conds = [
    ...
    [Spree.t(:under_price, price: format_price(1)),   { range: { price: { lt: 1 } } }],
    ...
  ]
  ```

4. Ensure that `Spree::Taxon#applicable_filters` returns the filters you want:

  ```
  # app/models/spree/taxon_decorator.rb
  def applicable_filters
    filters = []
    ...
    filters << Spree::Core::SearchkickFilters.price_filter if Spree::Core::SearchkickFilters.respond_to?(:price_filter)
    ...
    filters
  end
  ```

Advanced Filtering
------------------
Checkout out the wiki page [here](https://github.com/elevatorup/solidus_searchkick/wiki/Advanced-Filtering).

Autocomplete
------------
By default, SolidusSearchkick provides autocomplete for the `name` field of your products. In order to get this working, all you need to do is add the following lines to the corresponding files:

application.js
```
//= require spree/frontend/typeahead.bundle
//= require spree/frontend/solidus_searchkick
```

application.css
```
*= require spree/frontend/solidus_searchkick
```

After that, automplete should now be working in the search box.

_**Note:** These requires are not added by the generator in order to give you the option to add Autocomplete instead of forcing it._

Advanced Autocomplete
---------------------
The default autocomplete provided by solidus_searchkick is pretty basic.

In order to modify how the autocomplete for your site works, you will first need to create a `product_decorator` if you do not already have one.
You will then need to override the `self.autocomplete` method in order to suit your needs. Take a look at the `self.autocomplete` method in the solidus_searchkick `product_decorator` to get started.

```
# app/models/spree/product_decorator.rb
Spree::Product.class_eval do
...
  def self.autocomplete(keywords)
  ...
  end
...
end
```

Searchkick Options
------------------
Since SolidusSearchkick uses Searchkick to interact with ElasticSearch, it also accepts all of the Searchkick options.

You can specify a limit or offset when searching, as well as any other options provided by Searchkick.
In order to use the options, all you need to do is to pass a `searchkick_options` hash along with your search.

```
searcher = build_searcher(params.deep_merge(searchkick_options: { limit: 6, offset: 100 }))
@products = searcher.retrieve_products
```

OR

```
search_params = {
  search: {
    price: {
      gt: 100
    }
  },
  searchkick_options: {
    order: {
      price: :asc
    },
    limit: 100
  }
}

searcher = build_searcher(params.merge(search_params))
@products = searcher.retrieve_products
```


ElasticSearch DSL
-----------------
There are times where even the power of Searchkick will not be enough to get you the results you need from ElasitcSearch.
In these cases, you can use the full power of the ElasticSearch DSL by passing in the `query` param.

```
query = {
  {
    'bool': {
      'must': [
        { 'match': { 'name':   'Product 1'} }
      ],
      'filter': [
        { 'range': { 'available_on': { 'gte': '2015-01-01' }}}
      ]
    }
  }
}

searcher = build_searcher(query: query)
@products = searcher.retrieve_products
```


Testing
-------

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_searchkick/factories'
```

Copyright (c) 2016 Jim Smith, released under the New BSD License


Special Thanks
--------------

SolidusSearchkick was heavily inspired by [spree_searchkick](https://github.com/ronzalo/spree_searchkick), which was used as a starting point to getting Solidus to work nicely with Searchkick.

Contributing
------------

1. Fork it ( https://github.com/elevatorup/solidus_searchkick/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request
