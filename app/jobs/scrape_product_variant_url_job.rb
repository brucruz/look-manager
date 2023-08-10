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
      scraped_product, scraped_variants = Scrapers::ProductScraper.new(url).scrape
      puts "Done scraping #{url}"

      ActiveRecord::Base.transaction do
        puts "Checking if product #{scraped_product["name"]} exists..."
        product_exists = Product.find_by(
          sku: scraped_product["sku"],
          store: scraped_product["store"]
        )

        puts "Creating product #{scraped_product["name"]}..." if product_exists.nil?
        product = Product.create(scraped_product) if product_exists.nil?

        puts "Updating product #{scraped_product["name"]}..." if product_exists.present?
        product = Product.update(product_exists.id, scraped_product) if product_exists.present?

        puts "Finished with product #{scraped_product["name"]}"

        puts "We found #{scraped_variants.count} variants while scraping #{url}"        
        scraped_variants.each do |variant|
          puts "Checking if product variant #{variant["full_name"]} exists..."
          variant_exists = ProductVariant.find_by(
            sku: variant["sku"],
            product_id: product.id
          )

          puts "Creating product variant #{variant["full_name"]}..." if variant_exists.nil?
          variant = ProductVariant.create(variant) if variant_exists.nil?

          puts "Updating product variant #{variant["full_name"]}..." if variant_exists.present?
          variant = ProductVariant.update(variant_exists.id, variant) if variant_exists.present?

          puts "Finished with variant #{variant["full_name"]}"
        end
      end

      puts "Saved last product #{scraped_product["name"]} and its #{scraped_variants.count} variants"

      return @product_variant
    rescue => e
      puts "Error scraping #{url}: #{e.message}"
      e.backtrace.each { |line| puts line }
    end
  end
end