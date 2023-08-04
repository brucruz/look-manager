module ProductsHelper
  include Pagy::Frontend

  def get_new_urls_from_products(urls)
    existing_urls = Product.bulk_existing_urls(urls)

    new_urls = urls - existing_urls

    return new_urls
  end
end
