module ProductVariantsHelper
  def get_new_urls_from_product_variants(urls)
    existing_urls = ProductVariant.bulk_existing_urls(urls)

    new_urls = urls - existing_urls

    return new_urls
  end
end
