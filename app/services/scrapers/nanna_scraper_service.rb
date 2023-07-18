require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::NannaScraperService
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

    script_loader = doc.css('script#vndajs').attr('data-variant').value

    if script_loader.present?
      # parse the corresponding JSON
      variants = JSON.parse(script_loader)
      scraped_product = variants.first
    else
      raise "No product found"
    end
    
    store_url = "https://www.nannananna.com.br"

    product = {}
    product["name"] = doc.css('h1.title').text().strip
    product["sku"] = scraped_product["sku"]
    product["description"] = doc.css('div.description').text()
    product["brand"] = 'Nanna'
    product["store"] = 'Nanna'
    product["url"] = @url
    product["store_url"] = store_url
    product["currency"] = "R$"
    
    product["images"] = doc
      .css('div.product-section div.swiper-container div.swiper-wrapper img.lazy')
      .select { |image| image["data-src"] }
      .map do |image|
        url = image["data-src"]
        get_big_image = url.sub('100x', '1000x')
        get_big_image
      end
    product["old_price"] = scraped_product["sale_price"] == scraped_product["price"] ? nil : scraped_product["price"]
    product["price"] = scraped_product["sale_price"]
    product["installment_quantity"] = scraped_product["installments"].length
    product["installment_value"] = scraped_product["installments"].last["price"].to_f
    product["available"] = scraped_product["available"]
    product["sizes"] = variants.map do |variant|
      size = variant["attribute1"].sub('Tam ', '')
      if size == "Único"
        size = "U"
      elsif size.include? ")"
        size = size.split(')').first.split('(').last
      else
        size = size
      end
      available = variant["available"]
      url = @url
      { size: size, available: available, url: url}
    end
    
    related_products = doc.css('div.section-produtos div.product-top a').map do |product|
      slug = product["href"]
      url = "#{store_url}#{slug}"
      url
    end

    return { product: product, related_products: related_products }
  end
end