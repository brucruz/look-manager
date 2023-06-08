require 'net/http'
require "uri"

class ChromiumScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    uri = ENV['SCRAPER_SERVICE_URL']

    response = Net::HTTP.get(URI(uri + "product/web?url=#{@url}"))
    scraped_product = JSON.parse(response)
    scraped_product.delete("sizes")

    @product = Product.create(scraped_product)

    @product
  end
end
