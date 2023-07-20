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
    
    store_url = "https://www.cabanacrafts.com.br"

    main_name = scraped_product["name"]

    product = {}
    product["name"] = main_name
    product["gender"] = 'female'
    product["brand"] = 'Cabana Crafts'
    product["store"] = 'Cabana Crafts'
    product["store_url"] = store_url
    
    sizes = scraped_product["variants"].map do |variant|
      key, value = variant.first
      variant = variant[key]
      size = variant["properties"]["property1"]["value"]
      size = size == "" ? "U" : size
      available = variant["stock"] > 0
      { size: size, available: available, url: @url}
    end

    variants = [
      {
        title: '',
        full_name: main_name,
        description: scraped_product["plain_description"].gsub('[espaco-entre-tabs]', "\n"),
        sku: scraped_product["reference"],
        old_price: scraped_product["on_sale"] ? scraped_product["price"] : nil,
        price: scraped_product["sale_price"],
        installment_quantity: scraped_product["installments"].length,
        installment_value: scraped_product["installments"].first.to_f,
        available: scraped_product["available"],
        url: @url,
        images: scraped_product["images"].map { |image| image["url"] },
        currency: "R$",
        sizes: sizes,
      }
    ]

    related_products = doc.css('div.products-wrap div.lista-produto div.images a').map do |product|
      slug = product["href"]
      url = "#{store_url}#{slug}"
      url
    end

    return {
      product: product,
      variants: variants,
      related_products: related_products
    }
  end
end