require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::CarolMacDowellScraperService
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

    applicationLdJson = doc.css('script[type="application/ld+json"]').last.text()

    if applicationLdJson.present?
      # parse the corresponding JSON
      json_schema = JSON.parse(applicationLdJson)
    else
      raise "No product found"
    end

    variants_form = doc.css('form.variations_form.cart').attr("data-product_variations")

    if variants_form.present?
      # parse the corresponding JSON
      variants_object = JSON.parse(variants_form)
    else
      raise "No product variants found"
    end
    
    store_url = "https://carolmacdowell.com.br"

    images = doc
    .css('div.woocommerce-product-gallery div.woocommerce-product-gallery__image a img')
    .map { |image| image["src"] }

    main_name = json_schema["name"]
    
    product = {}
    product["name"] = main_name
    product["description"] = json_schema["description"]
    product["brand"] = 'Carol Mac Dowell'
    product["store"] = 'Carol Mac Dowell'
    # product["url"] = @url
    product["store_url"] = store_url
    # product["currency"] = "R$"
    
    variants = variants_object.map do |variant|
      color = variant["attributes"]["attribute_pa_cor"].capitalize
      materials = variant["variation_description"].split('<p>Materiais: ').last.split('</p>').first
      title = "#{color} (#{materials})"
      full_name = "#{main_name} - #{title}"

      sku = variant["sku"] + "_" + variant["variation_id"].to_s

      regular_price = variant["display_regular_price"]
      promo_price = variant["display_price"]

      if promo_price == regular_price
        old_price = nil
        price = regular_price
      else
        old_price = regular_price
        price = promo_price
      end

      available = variant["is_in_stock"]

      variant_image_prefix = variant["image"]["title"].split('1').first
      variant_images = images.select { |image| image.include?(variant_image_prefix) }

      {
        title: title,
        full_name: full_name,
        sku: sku,
        old_price: old_price,
        price: price,
        installment_value: price,
        installment_quantity: 1,
        available: available,
        url: @url,
        images: variant_images,
        currency: "R$",
      }
    end
    
    related_products = doc.css('div.section-produtos div.product-top a').map do |product|
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