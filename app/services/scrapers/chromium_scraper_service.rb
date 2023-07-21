require 'net/http'
require "uri"

class Scrapers::ChromiumScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    begin 
      uri = ENV['SCRAPER_SERVICE_URL']

      response = Net::HTTP.get_response(URI(uri + "product/web?url=#{@url}"))

      if response.code != '200'
        p response
        raise Exception.new(response)
      end

      result = JSON.parse(response.body)

      product = result["product"]
      variants = result["variants"]
      related_products = result["related"]

      if result["message"].present?
        p result
        raise result["message"]
      end

      return {
        product: product,
        variants: variants,
        related_products: related_products,
      }
    rescue => e
      p e
      raise e
    end
  end
end