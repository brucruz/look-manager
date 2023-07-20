require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::NannaScraperService
  include ApplicationHelper

  def initialize(url)
    @url = url
    @store_url = "https://www.nannananna.com.br"
  end

  def scrape
    page_doc = get_doc_from_page(@url)

    product = {}
    product["brand"] = 'Nanna'
    product["store"] = 'Nanna'
    product["url"] = @url
    product["store_url"] = @store_url
    product["gender"] = 'female'
    
    variants = []
    related_products = []
    
    variants1_data = get_variant_data(page_doc, @url)
    variants.push(variants1_data)

    other_variants = page_doc.css('div.section-produtos.cores div.carrosel-produtos div.item article div.product-top a')

    other_variants_urls = other_variants.map do |variant|
      variant_url = "#{@store_url}#{variant["href"]}"
      variant_url
    end

    other_variants_urls.each do |variant_url|
      doc = get_doc_from_page(variant_url)
      variant_data = get_variant_data(doc, variant_url)
      variants.push(variant_data)

      related_products_data = get_related_products(doc)
      related_products.push(*related_products_data)
    end

    # get the sku prefix from all skus using the common_prefix application helper
    sku_prefix = common_prefix(variants.map { |variant| variant[:sku] }).strip
    
    # get the name prefix from all names using the common_prefix application helper
    name_prefix = common_prefix(variants.map { |variant| variant[:full_name] }).strip

    product["name"] = name_prefix
    product["sku"] = sku_prefix

    # now, for every variant, add the title, which is the name without the prefix
    variants.map do |variant|
      variant[:title] = variant[:full_name].gsub(name_prefix, '').strip.capitalize
      variants
    end

    related_products1 = get_related_products(page_doc)
    related_products.push(*related_products1)

    return {
      product: product,
      variants: variants,
      # remove duplicates from related products
      related_products: related_products.uniq { |related_product| related_product },
    }
  end

  private

  def get_doc_from_page(url)
    uri = URI.parse(url)

    uri_path = uri.path

    response = Net::HTTP.get_response(uri)

    if (response.code != "200")
      raise "Error scraping product"
    end

    html = response.body

    doc = Nokogiri::HTML(html)

    doc
  end

  private

  def get_variant_data(doc, url)
    script_loader = doc.css('script#vndajs').attr('data-variant').value

    if script_loader.present?
      # parse the corresponding JSON
      variants = JSON.parse(script_loader)
      scraped_product = variants.first
      
      scraped_product
    else
      raise "No product found"
    end

    full_name = doc.css('h1.title').text().strip.capitalize
    sku = scraped_product["sku"].split('-').first
    description = doc.css('div.description').text()
    images = doc
      .css('div.product-section div.swiper-container div.swiper-wrapper img.lazy')
      .select { |image| image["data-src"] }
      .map do |image|
        url = image["data-src"]
        get_big_image = url.sub('100x', '1000x')
        get_big_image
      end
    old_price = scraped_product["sale_price"] == scraped_product["price"] ? nil : scraped_product["price"]
    price = scraped_product["sale_price"]
    installment_quantity = scraped_product["installments"].length
    installment_value = scraped_product["installments"].last["price"].to_f
    available = scraped_product["available"]
    sizes = variants.map do |variant|
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

    {
      full_name: full_name,
      sku: sku,
      description: description,
      images: images,
      currency: "R$",
      old_price: old_price,
      price: price,
      installment_quantity: installment_quantity,
      installment_value: installment_value,
      available: available,
      url: url,
      sizes: sizes,
    }
  end

  private

  def get_related_products(doc)
    related_products = doc.css('div.section-products div.section-produtos div.product-top a').map do |product|
      slug = product["href"]
      url = "#{@store_url}#{slug}"
      url
    end

    related_products
  end
end