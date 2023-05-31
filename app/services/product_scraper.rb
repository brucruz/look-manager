require 'tanakai'

# Create a new Tanakai scraper
class ProductScraper < Tanakai::Base
  @name = 'product_scraper'
  @engine = :selenium_chrome
  @@scraped_product = {}

  def self.process(url)
    @start_urls = [url]
    self.crawl!
  end

  def self.scraped_product
    @@scraped_product
  end

  def parse(response, url:, data: {})
    # Scrape the product information using CSS selectors
    product_div = response.css('.product-essential')

    scraped_product = {}

    scraped_product[:name] = product_div.css('.produt-title--name').text.strip
    scraped_product[:sku] = product_div.css('.product--sku').text.strip
    scraped_product[:brand] = product_div.css('.produt-title--brand a').text.strip
    scraped_product[:description] = product_div.css('.stylesTips .panel-body').text.strip
    
    regular_price = product_div.css('.regular-price span.price').text.strip
    
    if regular_price.empty?
      scraped_product[:old_price] = getValue(product_div.css('.product-price span.price[id^=old]').text.strip)
      scraped_product[:price] = getValue(product_div.css('.product-price span.price[id^=product]').text.strip)
    else
      scraped_product[:price] = getValue(regular_price)
    end

    installment_value = product_div.css('.product-price .product-installment').text.strip.split("x de ")[1].strip
    scraped_product[:currency] = installment_value.scan(/[A-Z]{1}\$/).first
    scraped_product[:installment_value] = installment_value.gsub(/[^\d,]/, '').gsub(',', '.').to_f
    scraped_product[:installment_quantity] = product_div.css('.product-price .product-installment').text.strip.split("x de ")[0].to_i

    available = product_div.attr('class')
    scraped_product[:available] = available ? !available.include?('out-of-stock') : false

    scraped_product[:url] = url
    scraped_product[:store_url] = "https://oqvestir.com.br"
    scraped_product[:store] = "OQVestir"

    scraped_product[:images] = product_div.css(".slick-cloned img").map do |img|
      img.attr("src")
    end

    # sizes = product_div.css('#attribute185 option')
    #   .filter(function () {
    #     return $(this).attr("data-label") !== undefined;
    #   })
    #   .map(function () {
    #     size = $(this).attr("data-label") || "not-found";
    #     available = !$(this).attr("class")?.includes

    # Add the scraped product to the database
    @product = Product.create(scraped_product)

    scraped_product[:id] = @product.id

    # Add the scraped product images to the database
    # images.each do |image|
    #   @product.product_images.create(url: image)
    # end

    @@scraped_product = scraped_product
  end

  def getValue(text)
    text.strip.gsub(/[^\d,]/, '').gsub(',', '.').to_f
  end
  
end