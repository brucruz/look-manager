require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::OffpremiumScraperService
  def initialize(url)
    @url = url
  end

  def scrape
    product_data = fetch_product_from_offpremium(@url)

    main_name = product_data["isVariantOf"]["name"]

    product_sku = product_data["gtin"].split('_')[0]

    product = {}
    product["name"] = main_name
    product["sku"] = product_sku
    product["brand"] = product_data["brand"]["name"]
    product["store"] = "Off Premium"
    product["url"] = @url
    product["store_url"] = "offpremium.com.br"

    breadcrumb_list = product_data["breadcrumbList"]["itemListElement"].map { |item| item["item"] }

    is_female = breadcrumb_list.any? { |breadcrumb| breadcrumb.include?("femin") }
    is_male = breadcrumb_list.any? { |breadcrumb| breadcrumb.include?("mascul") }

    product["gender"] = is_female ? 'female' : is_male ? 'male' : nil

    variants = []
    
    current_variant = parse_variant_data(product_data)
    variants << current_variant

    product_group_id = product_data["isVariantOf"]["productGroupID"]

    other_variants_urls = fetch_variants_urls_from_offpremium_server(product_group_id)

    if other_variants_urls.count > 0
      for url in other_variants_urls do
        variant_data = fetch_product_from_offpremium(url)
        variant = parse_variant_data(variant_data)
        variants << variant
      end
    end


    return { product: product, variants: variants }
  end

  def fetch_product_from_offpremium(url)
    uri = URI.parse(url)

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
  end

  def fetch_variants_urls_from_offpremium_server (product_group_id)
    body = "{\"operationName\":\"Similars\",\"variables\":{\"id\":\"" + product_group_id + "\"}}"

    url = 'https://www.offpremium.com.br/api/graphql?operationName=Similars'
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'application/json'
    request.body = body

    response = http.request(request)

    other_variants_url = JSON.parse(response.body)["data"]["productSimilars"].map { |variant| "https://www.offpremium.com.br" + variant["link"] }

    other_variants_url
  end

  def parse_variant_data(product_data)
    main_name = product_data["isVariantOf"]["name"]
    title = product_data["isVariantOf"]["variants"][0]["name"].split(' - ')[0]
    full_name = "#{main_name} - #{title}"

    product_sku = product_data["gtin"].split('_')[0]
    variant_sku = "#{product_sku}_#{product_data["gtin"].split('_')[1]}"
    size_sku = product_data["gtin"]

    sizes = product_data["isVariantOf"]["variants"].map do |variant|
      size = variant["attributes"][0]["value"]
      available = variant["offers"]["offers"][0]["availability"] === "https://schema.org/InStock"
      url = URI.parse(@url).hostname + "/" + variant["slug"]
      
      { size: size, available: available, url: url }
    end

    {
      title: title,
      full_name: full_name,
      sku: variant_sku,
      description:
        product_data["description"] + "\n\n" + product_data["composition"]["values"].join("\n"),
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
  end
end
