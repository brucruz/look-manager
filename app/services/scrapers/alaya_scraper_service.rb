require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::AlayaScraperService
  include ApplicationHelper
  
  def initialize(url)
    @url = url
  end

  def scrape
    alaya_response = fetch_product_from_alaya(@url)

    product_doc = alaya_response[:product_doc]
    product_details_doc = alaya_response[:product_details_doc]
    product_data = alaya_response[:product_data]
    other_variants_urls = alaya_response[:variations_urls]
    related = alaya_response[:related_urls]

    name = get_name(product_doc)

    product = {}
    product["name"] = name[:product_name]
    product["brand"] = "Alaya"
    product["store"] = "Alaya"
    product["url"] = @url
    product["store_url"] = "alayabrand.com"
    product["gender"] = 'female'

    variants = []
    related = []
    
    current_variant = parse_variant_data(
      product_doc,
      product_details_doc,
      product_data,
      @url
    )
    variants << current_variant

    if other_variants_urls.count > 0
      for url in other_variants_urls do
        variant_response = fetch_product_from_alaya(url)
        
        variant_doc = variant_response[:product_doc]
        variant_details_doc = variant_response[:product_details_doc]
        variant_data = variant_response[:product_data]

        variant = parse_variant_data(
          variant_doc,
          variant_details_doc,
          variant_data,
          url
        )

        variants << variant
      end
    end

    # get the sku prefix from all skus using the common_prefix application helper
    sku_prefix = common_prefix(variants.map { |variant| variant[:sku] }).strip
    product["sku"] = sku_prefix

    return { product: product, variants: variants, related_products: related }
  end

  def fetch_product_from_alaya(url)
    uri = URI.parse(url)

    response = Net::HTTP.get_response(uri)
    html = response.body

    doc = Nokogiri::HTML(html)

    product_doc = doc.css('#content section:not(.elementor-hidden-desktop)').first()
    product_details_doc = doc.css('div#elementor-tab-content-2092')
    product_sizes_form = doc.css('form.variations_form').attr('data-product_variations')
    variations_urls = doc.css('div.elementor-hidden-mobile div.wpclv-terms a').map { |a| a.attr('href') }
    related_urls = doc
      .css('div[data-widget_type="woocommerce-product-upsell.default"] ul li.product div.woocommerce-image__wrapper a')
      .map { |a| a.attr('href') }

    @data_product_id = doc.css('form.variations_form').attr('data-product_id')
    
    if product_doc.present? && product_sizes_form.present?
      # parse the corresponding JSON
      product_data = JSON.parse(product_sizes_form)
    else
      raise "No product found"
    end

    return {
      product_doc: product_doc,
      product_details_doc: product_details_doc,
      product_data: product_data,
      variations_urls: variations_urls,
      related_urls: related_urls,
    }
  end

  def parse_variant_data(doc, product_details_doc, product_data, url)
    name = get_name(doc)

    variant_sku = product_data.first["sku"].split('-').first

    description_css = doc.css('.woocommerce-product-details__short-description')
    # substitute the <br> tags with new lines (\n)
    description_css.search('br').each { |br| br.replace("\n") }

    details_css = product_details_doc.css('div#elementor-tab-content-2092')
    # substitute the <br> tags with new lines (\n)
    details_css.search('br').each { |br| br.replace("\n") }

    description = description_css.text.strip + "\n\n" + details_css.text.strip

    images = get_images();

    display_price = product_data.first["display_price"]
    display_regular_price = product_data.first["display_regular_price"]
    
    hasPromotionalPrice = display_price < display_regular_price
    
    if hasPromotionalPrice
      old_price = display_regular_price;
      price = display_price;
    else
      price = display_regular_price;
    end

    sizes = product_data.map do |variation|
      size = variation["attributes"]["attribute_pa_tamanhos"];
      available = variation["is_in_stock"];

      {
        size: size,
        available: available,
        url: url,
      }
    end

    available = sizes.any? { |size| size[:available] }

    {
      title: name[:variant_title],
      full_name: name[:variant_full_name],
      sku: variant_sku,
      description: description,
      images: images,
      currency: "R$",
      old_price: old_price,
      price: price,
      available: available,
      url: url,
      sizes: sizes,
    }
  end

  def get_name(productDiv)
    name = productDiv.css("h1.product_title").text.strip
    variant_full_name = name
    product_name = name.split(" – ").first
    variant_title = name.split(" – ").second

    {
      variant_full_name: variant_full_name,
      product_name: product_name,
      variant_title: variant_title
    }
  end

  def get_images()
    url = URI("https://alayabrand.com/wp-admin/admin-ajax.php")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'multipart/form-data; boundary=---011000010111000001101001'
    request.body =
      "-----011000010111000001101001\r\nContent-Disposition: form-data; " +
      "name=\"action\"\r\n\r\nwoocommerce_get_gallery_images\r\n" +
      "-----011000010111000001101001\r\nContent-Disposition: form-data; " +
      "name=\"product_id\"\r\n\r\n#{@data_product_id}\r\n" +
      "-----011000010111000001101001--\r\n"

    response = http.request(request)

    images = JSON.parse(response.body)["images"].map do |image|
      image["full"]
      # match between src=" and the next "
        .match(/(?<=src=").*?(?=")/).to_s
    end
  end
end
