require 'capybara'
require 'capybara/dsl'

class OqvestirScraper
  include Capybara::DSL

  def initialize(url)
    @url = url
    configure_capybara
  end

  def scrape
    puts 'Started to scrape page: ' + @url
    visit(@url)

    product_div = find('.product-essential')

    scraped_product = {}

    scraped_product[:name] = product_div.find('.produt-title--name').text.strip
    scraped_product[:sku] = product_div.find('.product--sku').text.strip
    scraped_product[:brand] = product_div.find('.produt-title--brand a').text.strip
    scraped_product[:description] = product_div.has_css?('.stylesTips .panel-body') ?
      find('.stylesTips .panel-body').text.strip :
      find('.panel-body li', match: :first).text.strip

    regular_price = product_div.has_css?('.regular-price span.price')

    if regular_price
      scraped_product[:price] = getValue(product_div.find('.regular-price span.price').text.strip)
    else
      scraped_product[:old_price] = getValue(product_div.find('.product-price span.price[id^=old]').text.strip)
      scraped_product[:price] = getValue(product_div.find('.product-price span.price[id^=product]').text.strip)
    end

    installment_value = product_div.find('.product-price .product-installment').text.strip.upcase.split("X DE ")[1].strip
    scraped_product[:currency] = installment_value.scan(/[A-Z]{1}\$/).first
    scraped_product[:installment_value] = installment_value.gsub(/[^\d,]/, '').gsub(',', '.').to_f
    scraped_product[:installment_quantity] = product_div.find('.product-price .product-installment').text.strip.upcase.split("X DE ")[0].to_i

    available = product_div.find('.availability')[:class]
    scraped_product[:available] = available ? !available.include?('out-of-stock') : false

    scraped_product[:url] = @url
    scraped_product[:store_url] = "https://oqvestir.com.br"
    scraped_product[:store] = "OQVestir"

    scraped_product[:images] = product_div.all(".slick-cloned img").map do |img|
      img[:src]
    end

    @product = Product.create(scraped_product)

    @product
  end

  def getValue(text)
    text.strip.gsub(/[^\d,]/, '').gsub(',', '.').to_f
  end

  private

  def configure_capybara
    Capybara.run_server = false
    Capybara.current_driver = :selenium_chrome_headless
    Capybara.app_host = 'https://www.oqvestir.com.br'
    Capybara.ignore_hidden_elements = false

    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new app, browser: :chrome,
        options: Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu disable-dev-shm-usage])
    end

    Capybara.javascript_driver = :chrome
  end
end