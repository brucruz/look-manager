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
      variants = result[:variants]
      # related_products = result[:related_products]

      # Create job to scrape related products
      # if related_products.present? && related_products.count > 0
      #   AddRelatedProductsJob.perform_later(related_products)
      # end

      return product, variants
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
      Scrapers::AlayaScraperService
    when 'offpremium.com.br'
      Scrapers::OffpremiumScraperService
    when 'cabanacrafts.com.br'
      Scrapers::CabanaCraftsScraperService
    when 'nannananna.com.br'
      Scrapers::NannaScraperService
    when 'carolmacdowell.com.br'
      Scrapers::CarolMacDowellScraperService
    when 'manolita.com.br'
      Scrapers::ManolitaScraperService
    when 'usequattre.com.br'
      Scrapers::QuattreScraperService
    when 'onnistore.com.br'
      Scrapers::OnniScraperService
    else
      nil
    end
  end
end
