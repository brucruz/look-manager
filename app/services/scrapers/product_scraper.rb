class Scrapers::ProductScraper
  def initialize(url)
    @url = url
  end

  def scrape
    hostname = remove_www(get_hostname(@url))
    scraper_class = scraper_class_for(hostname)

    if scraper_class
      scraper = scraper_class.new(@url)
      result = scraper.scrape
      product = result[:product]
      related_products = result[:related_products]

      # Create job to scrape related products
      AddRelatedProductsJob.perform_later(related_products)

      return product
    else
      raise "No scraper available for the given URL"
    end
  end

  private

  def get_hostname(url)
    uri = URI.parse(url)
    uri.host
  rescue URI::InvalidURIError
    nil
  end

  private

  def remove_www(hostname)
    if hostname.starts_with?('www.')
      hostname.slice!('www.')
    end
    hostname
  end

  private

  def scraper_class_for(hostname)
    case hostname
    when 'oqvestir.com.br'
      Scrapers::ChromiumScraperService
    when 'shop2gether.com.br'
      Scrapers::ChromiumScraperService
    when 'alayabrand.com'
      Scrapers::ChromiumScraperService
    when 'offpremium.com.br'
      Scrapers::OffpremiumScraperService
    else
      nil
    end
  end
end
