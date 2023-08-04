class ScrapeProductVariantUrlJob < ApplicationJob
  queue_as :default

  def perform(url)
    begin
      puts "Checking if product variant #{url} is already in the database"
      product_variant_exists = ProductVariant.exists?(url: url)

      if product_variant_exists
        puts "Product variant #{url} already in the database"
        return
      end
      
      puts "Scraping #{url}"
      product_variant = Scrapers::ProductScraper.new(url).scrape

      puts "Saving product variant #{product_variant["full_name"]}"
      @product_variant = ProductVariant.create(product_variant)

      puts "Done scraping #{url}"
      return @product_variant
    rescue => e
      puts "Error scraping #{url}: #{e.message}"
    end
  end
end