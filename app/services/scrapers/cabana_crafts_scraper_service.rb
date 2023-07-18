require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::CabanaCraftsScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    uri = URI.parse(@url)

    uri_path = uri.path

    response = Net::HTTP.get_response(uri)

    if (response.code != "200")
      raise "Error scraping product"
    end

    html = response.body

    doc = Nokogiri::HTML(html)

    script_loader = doc.css("script:contains('console.log({')")
    
    if script_loader.present?
      # get all text between `console.log(` and `);`
      json = script_loader.text.split("console.log(").last.split(");").first
      # parse the corresponding JSON
      scraped_product = JSON.parse(json)
    else
      raise "No product found"
    end

    product = {}
    product["name"] = scraped_product["name"]
    product["sku"] = scraped_product["id"]
    product["description"] = scraped_product["plain_description"].gsub('[espaco-entre-tabs]', "\n")
    product["brand"] = 'Cabana Crafts'
    product["store"] = 'Cabana Crafts'
    product["url"] = @url
    product["store_url"] = "cabanacrafts.com.br"
    product["currency"] = "R$"
    product["images"] = scraped_product["images"].map { |image| image["url"] }
    product["old_price"] = scraped_product["on_sale"] ? scraped_product["price"] : nil
    product["price"] = scraped_product["sale_price"]
    product["installment_quantity"] = scraped_product["installments"].length
    product["installment_value"] = scraped_product["installments"].second.to_f
    product["available"] = scraped_product["available"]
    product["sizes"] = scraped_product["variants"].map do |variant|
      key, value = variant.first
      variant = variant[key]
      size = variant["properties"]["property1"]["value"]
      size = size == "" ? "U" : size
      available = variant["stock"] > 0
      { size: size, available: available, url: @url}
    end

    related_products = doc.css('div.products-wrap div.lista-produto div.images a').map do |product|
      slug = product["href"]
      url = "https://www.cabanacrafts.com.br#{slug}"
      url
    end

    return { product: product, related_products: related_products }
  end
end