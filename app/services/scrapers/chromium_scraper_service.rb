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

      if response.kind_of? Net::HTTPError do
        p response
        raise Exception.new(response)
      end

      result = JSON.parse(response)

      product = result["product"]
      related_products = result["related"]

      if result["message"].present?
        p result
        raise result["message"]
      end

      return { product: product, related_products: related_products }
    rescue => e
      p e
      raise e
    end
  end
end