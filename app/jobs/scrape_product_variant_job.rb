class ScrapeProductVariantJob < ApplicationJob
  queue_as :default

  def perform(*args)
    begin
      product_variant = args[0]
      product = product_variant.product
      
      # scrape product from the web
      puts("Scraping product #{product_variant.full_name} last information")
      scraper = Scrapers::ProductScraper.new(product_variant.url)
      scraped_product, scraped_variants = scraper.scrape

      scraped_object = {
        "product" => scraped_product,
        "variants" => scraped_variants,
      }

      product_object = {
        "product" => product,
        "variants" => [product_variant],
      }

      # get product update object
      puts("Getting product #{product_variant.full_name} update object")
      update_object = GetProductUpdateObjectService.new(product_object, scraped_object).call

      # update product
      ActiveRecord::Base.transaction do
        update_product = update_object["product"]
        update_variants = update_object["variants"]

        puts("Updating product #{product.name}")
        @updated_product = product.update(update_product)
        
        @updated_variants = []
        for variant in update_variants
          existing_variant = ProductVariant.find_by(url: variant["url"])
          
          updated_variant = existing_variant.update(variant) if existing_variant.present?
          updated_variant = ProductVariant.create(variant) if existing_variant.nil?

          @updated_variants << updated_variant
        end
      end
      
      { updated_product: @updated_product, updated_variants: @updated_variants }

    rescue => exception
      # TODO: Add error handling for when the product is not found
      puts("Error scraping product variant #{product_variant.full_name}: #{exception}")
    end
  end
end
