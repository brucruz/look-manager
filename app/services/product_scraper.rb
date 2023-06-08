class ProductScraper
  def initialize(url)
    @url = url
  end

  def scrape
    hostname = remove_www(get_hostname(@url))
    scraper_class = scraper_class_for(hostname)

    if scraper_class
      scraper = scraper_class.new(@url)
      scraper.scrape
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

  def remove_www(hostname)
    if hostname.starts_with?('www.')
      hostname.slice!('www.')
    end
    hostname
  end

  def scraper_class_for(hostname)
    case hostname
    when 'oqvestir.com.br'
      ChromiumScraperService
    when 'shop2gether.com.br'
      ChromiumScraperService
    else
      nil
    end
  end
end