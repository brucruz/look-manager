require "nokogiri"
require 'net/http'
require "uri"

class Scrapers::OnniScraperService
  include ApplicationHelper
  
  def initialize(url)
    @url = url
  end

  def scrape
    onni_response = fetch_product_from_onni(@url)

    breadcrumbs = onni_response[:breadcrumbs]
    product_doc = onni_response[:product_doc]
    sizes_data = onni_response[:sizes_data]
    variations_urls = onni_response[:variations_urls]

    product = {}
    product["brand"] = "onni"
    product["store"] = "onni"
    product["store_url"] = "onnistore.com.br"
    
    is_male = breadcrumbs.any? { |el| el.include?("masculin") }
    is_female = breadcrumbs.any? { |el| el.include?("feminin") }
    product["gender"] = is_male ? 'male' : is_female ? 'female' : nil

    variants = []
    @full_names = []
    @skus = []
    
    current_variant = parse_variant_data(
      product_doc,
      sizes_data,
      @url
    )
    variants << current_variant

    if variations_urls.count > 0
      for url in variations_urls do
        variant_response = fetch_product_from_onni(url)

        next if variant_response.nil?

        variant_doc = variant_response[:product_doc]
        variant_sizes_data = variant_response[:sizes_data]

        variant = parse_variant_data(
          variant_doc,
          variant_sizes_data,
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

  def fetch_product_from_onni(url)
    puts "Fetching product from onni: #{url}"
    
    uri = URI.parse(url)

    response = Net::HTTP.get_response(uri)
    
    if response.code == "200"
      html = response.body

      doc = Nokogiri::HTML(html)

      breadcrumbs = doc.css('div.main div.breadcrumbs ul li')[1..-1].map { |li| li.text.downcase.strip }
      product_doc = doc.css('div.main div.product-view div.product-essential')
      sizes_data = JSON.parse(
        doc.css('script:contains("window.dataLayer.push(")')
          .first.text
          .split('window.dataLayer.push(').second
          .gsub(');', '')
      )
      variations_urls = product_doc.css('div.block-related ol.mini-products-list li.item div.product a.product-image').map { |a| a.attr("href") }

      return {
        breadcrumbs: breadcrumbs,
        product_doc: product_doc,
        sizes_data: sizes_data,
        # remove the current url from the variations urls to avoid scraping the same product twice
        variations_urls: variations_urls.select { |url| url != @url },
      }
    end
  end

  def parse_variant_data(doc, sizes_data, url)
    full_name = sizes_data["productName"]
    puts "parsing variant: #{full_name}..."
    @full_names << full_name

    variant_sku = sizes_data["productSku"]
    @skus << variant_sku

    description_css = doc.css('div.short-description div.std')
    # substitute the <br> tags with new lines (\n)
    description_css.search('br').each { |br| br.replace("\n") }

    all_sizes = []
    
    description_array = doc
      .css('div.add-to-cart-wrapper div.product-collateral dl.collateral-tabs dd.tab-container p')
      .map do |p|
        p.search('br').each { |br| br.replace("\n") }
        all_sizes = p.text.strip if p.text.strip.include?("cm | ")
        p.text.strip
      end
    
    description = description_css.text.strip + "\n" + description_array.join("\n")

    images = doc.css('div.product-img-box div.MagicToolboxSelectorsContainer div a img').map do |img|
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

    installments = doc.css('div.price-info div.price-box span.precoparcelado-parcels').text.strip
    installment_quantity = installments.split('x de ').first.strip.to_i
    installment_value = get_pt_br_number(installments.split('x de ').last.strip)

    ## from all_sizes = 'PP - Busto: 84 - 88 cm | Cintura: 66 - 70 cm | Quadril: 92 - 96 cm\nP - Busto: 88 - 92 cm | Cintura: 70 - 74 cm | Quadril: 96 - 100 cm\nM - Busto: 92 - 96 cm | Cintura: 74 - 78 cm | Quadril: 100 - 104 cm\nG - Busto: 96 - 100 cm | Cintura: 78 - 82 cm | Quadril: 104 - 108 cm'
    # get all the sizes: all_sizes = ['PP', 'P', 'M', 'G']
    all_sizes = all_sizes.split("\n").map { |size| size.split(" - ").first }
    
    available_sizes = doc.css('dd.clearfix div.input-box ul li span.swatch-label').map { |span| span.text.strip }

    sizes = all_sizes.map do |size|
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
      old_price: old_price,
      price: price,
      installment_quantity: installment_quantity,
      installment_value: installment_value,
      available: available,
      url: url,
      sizes: sizes,
    }
  end
end
