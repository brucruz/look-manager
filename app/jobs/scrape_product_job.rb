class ScrapeProductJob < ApplicationJob
  queue_as :default

  def perform(*args)
    begin
      product = args[0]
      
      # scrape product from the web
      puts("Scraping product #{product.name} last information")
      scraper = Scrapers::ProductScraper.new(product.url)
      scraped_product = scraper.scrape

      # get product update object
      puts("Getting product #{product.name} update object")
      update_object = GetProductUpdateObjectService.new(product, scraped_product).call

      # update product
      puts("Updating product #{product.name}")
      updated_product = product.update(update_object)

      puts("Product #{product.name} updated")
      updated_product
    rescue => exception
      # TODO: Add error handling for when the product is not found
      puts("Error scraping product #{product.name}: #{exception}")
    end
  end

  private

  def product_params
    params.require(:product).permit(
      :name,
      :sku,
      :brand,
      :store,
      :url,
      :store_url,
      :description,
      :currency,
      :old_price,
      :price,
      :installment_quantity,
      :installment_value,
      :available,
      images: [],
      sizes: [],
    )
  end
end
