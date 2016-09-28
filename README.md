[![Build Status](https://travis-ci.org/elevatorup/solidus_searchkick.svg?branch=master)](https://travis-ci.org/elevatorup/solidus_searchkick)
[![Code Climate](https://codeclimate.com/github/elevatorup/solidus_searchkick/badges/gpa.svg)](https://codeclimate.com/github/elevatorup/solidus_searchkick)
[![Test Coverage](https://codeclimate.com/github/elevatorup/solidus_searchkick/badges/coverage.svg)](https://codeclimate.com/github/elevatorup/solidus_searchkick/coverage)

Solidus + Searchkick
===============

Add [Elasticsearch](http://elastic.co) goodies to Solidus, powered by [searchkick](http://searchkick.org).

Features
--------

* Full search (keyword, in_taxon)
* Taxons Aggregations (aggs)
* Search Autocomplete ([Typeahead](https://twitter.github.io/typeahead.js/))


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

OR

rake solidus_searchkick:install:migrations
```

[Install elasticsearch](https://www.elastic.co/downloads/elasticsearch)

Documentation
-------------

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
* All Properies
* All Taxon ids by Taxonomy

In order to control what data is indexed, override `Spree::Product#search_data` method. Call `Spree::Product.reindex` after changing this method.

To enable or disable taxons filters, go to taxonomy form and change `filterable` boolean.

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