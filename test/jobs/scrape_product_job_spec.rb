require 'rails_helper'

RSpec.describe ScrapeProductJob do
  context "When testing the ScrapeProductJob class" do
    it "should update product with scraped data" do
      product = Product.new(name: Faker::Commerce.product_name,
        sku: Faker::Alphanumeric.alpha(number: 10),
        brand: Faker::Commerce.brand,
        store: Faker::Commerce.vendor,
        url: Faker::Internet.url,
        store_url: Faker::Internet.url,
        description: Faker::Quote.yoda,
        currency: 'BRL',
        images: [Faker::Internet.url,Faker::Internet.url],
        old_price: Faker::Commerce.price * 2,
        price: Faker::Commerce.price / 2,
        installment_quantity: Faker::Number.between(from: 1,
          to: 10),
        installment_value: Faker::Commerce.price / 5,
        available: true,
        sizes: [
          { S: true, url: Faker::Internet.url },
          { M: true, url: Faker::Internet.url}
        ]
      )

      product = ScrapeProductJob.new(product).perform_now

      expect(product[:name]).to be_a(String)
    end
  end
end
