module ProductsHelper
  def get_new_urls(urls)
    existing_urls = Product.bulk_existing_urls(urls)

    new_urls = urls - existing_urls

    return new_urls
  end
end
