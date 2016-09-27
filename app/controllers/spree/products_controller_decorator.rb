Spree::ProductsController.class_eval do
  def autocomplete
    keywords = params[:keywords] ||= nil
    json = Spree::Product.autocomplete(keywords)
    render json: json
  end
end
