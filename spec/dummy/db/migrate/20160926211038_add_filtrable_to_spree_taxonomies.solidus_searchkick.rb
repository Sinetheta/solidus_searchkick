# This migration comes from solidus_searchkick (originally 20150819222417)
class AddFiltrableToSpreeTaxonomies < ActiveRecord::Migration
  def change
    add_column :spree_taxonomies, :filterable, :boolean
  end
end
