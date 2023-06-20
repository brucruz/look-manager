require 'net/http'
require "uri"

class Scrapers::ChromiumScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    begin 
      uri = ENV['SCRAPER_SERVICE_URL']

      response = Net::HTTP.get(URI(uri + "product/web?url=#{@url}"))
      scraped_product = JSON.parse(response)

      if scraped_product["message"].present?
        p scraped_product
        raise scraped_product["message"]
      end

      scraped_product

      # @product = Product.create(scraped_product)

      # @product
    rescue => e
      p e
      raise e
    end
  end
end