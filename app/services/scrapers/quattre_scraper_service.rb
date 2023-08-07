require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::QuattreScraperService
  include ApplicationHelper
  
  def initialize(url)
    @url = url
  end

  def scrape
    quattre_response = fetch_product_from_quattre(@url)

    product_doc = quattre_response[:product_doc]
    variations_urls = quattre_response[:variations_urls]

    product = {}
    product["brand"] = "quattre"
    product["store"] = "quattre"
    product["store_url"] = "usequattre.com.br"
    product["gender"] = 'female'

    variants = []
    @full_names = []
    @skus = []
    
    current_variant = parse_variant_data(
      product_doc,
      @url
    )
    variants << current_variant

    if variations_urls.count > 0
      for url in variations_urls do
        variant_response = fetch_product_from_quattre(url)

        next if variant_response.nil?

        variant_doc = variant_response[:product_doc]

        variant = parse_variant_data(
          variant_doc,
          url
        )

        variants << variant
      end
    end

    # get the name prefix from all full names using the common_prefix application helper
    name_prefix = common_prefix(@full_names).strip
    product["name"] = name_prefix

    variants = variants.map do |variant|
      # get the name suffix from the variant full name and removing the name_prefix
      title = variant[:full_name].gsub(name_prefix, "").strip

      # return the variant with the new title and spread the other attributes
      { title: title, **variant }
    end

    # get the sku prefix from all skus using the common_prefix application helper
    sku_prefix = common_prefix(@skus).strip
    product["sku"] = sku_prefix

    return { product: product, variants: variants.uniq { |variant| variant[:sku] } }
  end

  def fetch_product_from_quattre(url)
    puts "Fetching product from quattre: #{url}"
    
    uri = URI.parse(url)

    response = Net::HTTP.get_response(uri)
    
    if response.code == "200"
      html = response.body

      doc = Nokogiri::HTML(html)

      product_doc = doc.css('div.main div.product-view div.product-essential')
      variations_urls = doc.css('div.cores-disponiveis a').map { |a| a.attr('href') }

      return {
        product_doc: product_doc,
        # remove the current url from the variations urls to avoid scraping the same product twice
        variations_urls: variations_urls.select { |url| url != @url },
      }
    end
  end

  def parse_variant_data(doc, url)
    full_name = doc.css('div.product-shop div.product-name span.h1').text.strip
    puts "parsing variant: #{full_name}..."
    @full_names << full_name

    variant_sku = full_name.parameterize
    @skus << variant_sku

    description_css = doc.css('div.short-description div.std')
    # substitute the <br> tags with new lines (\n)
    description_css.search('br').each { |br| br.replace("\n") }
    description = description_css.text.strip

    images = doc.css('div.product-image-gallery img.gallery-image').map do |img|
      img.attr('src')
    end

    special_price = doc.css('div.price-info div.price-box p.special-price span.price').text.strip

    if special_price.present?
      price = get_pt_br_number(special_price)
      old_price_str = doc.css('div.price-info div.price-box p.old-price span.price').text.strip
      old_price = get_pt_br_number(old_price_str)
    else
      price_str = doc.css('div.price-info div.price-box span.regular-price span.price').text.strip
      price = get_pt_br_number(price_str)
    end

    ## given a description with the following format:
    # - Fivela escovada
    # - 100% feito a mão
    # Tamanho 34 - 22.5 cm
    # Tamanho 35 - 23.0 cm
    # Tamanho 36 - 23.5 cm
    # Tamanho 37 - 24.0 cm
    # and so on...
    # we want to extract the sizes:
    # sizes = ["34", "35", "36", "37", ...]

    all_sizes = description.split("\n").select { |line| line.start_with?("Tamanho ") }.map do |line|
      line.split(" - ").first.gsub("Tamanho ", "").strip
    end
    available_sizes_str = doc
      .css('div.product-options script:contains("spConfig")')
      .text
      .split("spConfig = new Product.Config(").last
      .split(");").first
    available_sizes_json = JSON.parse(available_sizes_str)
    available_sizes = available_sizes_json["attributes"]["139"]["options"].map {|option| option["label"] }

    sizes = all_sizes.map do |size|
      size = size
      url = url
      available = available_sizes.include?(size)

      { size: size, available: available, url: url }
    end

    available = sizes.any? { |size| size[:available] }

    puts "parsed variant: #{full_name}"

    {
      full_name: full_name,
      sku: variant_sku,
      description: description,
      images: images,
      currency: "R$",
      price: price,
      available: available,
      url: @url,
      sizes: sizes,
    }
  end
end
