# 0.3.4
Updated cache_key_for_products (thanks @Sinetheta)

# 0.3.3
Updates default indexed currency to `Spree::Config.currency` instead of the products `cost_currency`.

# 0.3.1
Version 0.3.1 introduced a breaking change related to the index_name. If using a previous version of solidus_searchkick, you will need to either:
- reindex all of your products (which will build the index with the new name)
- update your product_decorator to use the index_name currently being used
