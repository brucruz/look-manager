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

      result = JSON.parse(response.body)
      
      case response.code
      when '200'
      when '404'
        case result["error"]
        ## TODO: Add the rest of the cases
        when 'Problem connecting to webpage: Product not found'
          p "#{result["error"]}: #{@url}"
          raise Scrapers::Errors::ProductNotFoundError.new("Product not found in #{@url}", @url)
        end
      else
        p response
        raise Exception.new(response)
      end
      
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