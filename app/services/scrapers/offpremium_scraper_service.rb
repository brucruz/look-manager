require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::OffpremiumScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    uri = URI.parse(@url)

    uri_path = uri.path
    # get the product id from the url (the last part of the path between the last "-"" and the last "/")
    product_id = uri_path.split("-").last.split("/").first

    response = Net::HTTP.get_response(uri)
    html = response.body

    doc = Nokogiri::HTML(html)

    gatsby_script_loader = doc.css('script[id="gatsby-script-loader"]')
    
    if gatsby_script_loader.present?
      # get all text between `"result":` and `,"staticQueryHashes"`
      json = gatsby_script_loader.text.match(/(?<="result":)(.*)(?=,"staticQueryHashes")/).to_s
      # parse the corresponding JSON
      scraped_product = JSON.parse(json)
    else
      raise "No product found"
    end

    # get the product data
    product_data = scraped_product["serverData"]["product"]

    product = {}
    product["sku"] = product_data["gtin"]
    product["brand"] = product_data["brand"]["name"]
    product["store"] = "Off Premium"
    product["url"] = @url
    product["store_url"] = "offpremium.com.br"

    breadcrumb_list = product_data["breadcrumbList"]["itemListElement"].map { |item| item["item"] }

    has_female_breadcrumb = breadcrumb_list.any? { |breadcrumb| breadcrumb.include?("femin") }
    has_male_breadcrumb = breadcrumb_list.any? { |breadcrumb| breadcrumb.include?("mascul") }

    if has_female_breadcrumb
      product["gender"] = 'female'
    elsif has_male_breadcrumb
      product["gender"] = 'male'
    else
    end

    debugger
    
    sizes = product_data["isVariantOf"]["variants"].map do |variant|
      size = variant["attributes"][0]["value"]
      available = variant["offers"]["offers"][0]["availability"] === "https://schema.org/InStock"
      url = uri.hostname + "/" + variant["slug"]
      
      { size: size, available: available, url: url }
    end

    variants = [
      {
        title: '',
        full_name: product_data["seo"]["title"],
        sku: product_data["gtin"],
        description: product_data["description"],
        images: product_data["image"].map { |image| image["url"] },
        currency: "R$",
        old_price: product_data["commertialOffers"][0]["listPrice"].to_f,
        price: product_data["commertialOffers"][0]["price"].to_f,
        installment_quantity: product_data["commertialOffers"][0]["installment"]["count"],
        installment_value: product_data["commertialOffers"][0]["installment"]["value"].to_f,
        available: product_data["offers"]["offers"][0]["availability"] === "http://schema.org/InStock" ? true : false,
        url: @url,
        sizes: sizes,
      }
    ]

    return { product: product, variants: variants }
  end
end
