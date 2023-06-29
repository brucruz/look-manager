class ScrapeProductUrlJob < ApplicationJob
  queue_as :default

  def perform(url)
    begin
      puts "Checking if product #{url} is already in the database"
      product_exists = Product.exists?(url: url)

      if product_exists
        puts "Product #{url} already in the database"
        return
      end
      
      puts "Scraping #{url}"
      product = Scrapers::ProductScraper.new(url).scrape

      puts "Saving product #{product["name"]}"
      @product = Product.create(product)

      puts "Done scraping #{url}"
      return @product
    rescue => e
      puts "Error scraping #{url}: #{e.message}"
    end
  end
end