class Scrapers::Errors::ProductNotFoundError < StandardError
  def initialize(message = "Product not found", url = nil)
    @url = url
    super(message)
  end

  attr_reader :url
end