require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::ManolitaScraperService
  include ApplicationHelper
  
  def initialize(url)
    @url = url
  end

  def scrape
    manolita_response = fetch_product_from_manolita(@url)

    product_doc = manolita_response[:product_doc]
    sizes_details = manolita_response[:sizes_details]
    other_variants_urls = manolita_response[:variations_urls]
    related_urls = manolita_response[:related_urls]



    product = {}
    product["brand"] = "manolita"
    product["store"] = "manolita"
    product["store_url"] = "manolita.com.br"
    product["gender"] = 'female'

    variants = []
    @full_names = []
    @skus = []
    
    current_variant = parse_variant_data(
      product_doc,
      sizes_details,
      @url
    )
    variants << current_variant

    if other_variants_urls.count > 0
      for url in other_variants_urls do
        full_url = "https://www.manolita.com.br#{url}"
        variant_response = fetch_product_from_manolita(full_url)
        
        variant_doc = variant_response[:product_doc]
        variant_size_details = variant_response[:sizes_details]
        
        related_urls.concat(variant_response[:related_urls])

        variant = parse_variant_data(
          variant_doc,
          variant_size_details,
          full_url
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

    return { product: product, variants: variants.uniq, related_products: related_urls.uniq }
  end

  def fetch_product_from_manolita(url)
    puts "Fetching product from manolita: #{url}"
    
    uri = URI.parse(url)

    response = Net::HTTP.get_response(uri)
    html = response.body

    doc = Nokogiri::HTML(html)

    product_doc = doc.css('div.product-section')
    sizes_details = JSON.parse(doc.css('script#vndajs').attr('data-variant'))
    variations_urls = doc.css('div.carrossel-cores div#cores div.item a').map { |a| a.attr('href') }
    related_urls = product_doc
      .css('div.relacionados div#relateds div.swiper-wrapper div.swiper-slide div.product-block a')
      .map { |a| a.attr('href') }

    return {
      product_doc: product_doc,
      sizes_details: sizes_details,
      variations_urls: variations_urls,
      related_urls: related_urls,
    }
  end

  def parse_variant_data(doc, details, url)
    detail = details.first

    full_name = doc.css('div.product-wrap div.product-infos div.main-infos h1.product-name').text.strip
    puts "parsing variant: #{full_name}..."
    @full_names << full_name

    skus = []

    description_css = doc.css('div.description span.text')
    # substitute the <br> tags with new lines (\n)
    description_css.search('br').each { |br| br.replace("\n") }
    description = description_css.text.strip

    images = doc.css('div.product-images div.swiper-wrapper div.item-image a img').map do |img|
      img.attr('src')
    end

    price = detail["price"]

    installments = detail["installments"]
    installment_quantity = installments.count
    installment_value = installments.last["price"]
    
    sizes = details.map do |variation|
      skus << variation["sku"]
      @skus << variation["sku"]
      size = variation["attribute2"]
      # the store considers a product available if it has at least 5 item in stock, but we want to show if > 0
      available = variation["stock"] > 0

      {
        size: size,
        available: available,
        url: url,
      }
    end

    variant_sku = common_prefix(skus).strip

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
