require 'rails_helper'

RSpec.describe ScrapeProductVariantJob do
  context "When testing the ScrapeProductVariantJob class" do
    it "should update product with scraped data" do
      product_variant = ProductVariant.new(
        title: Faker::Commerce.product_name,
        full_name: Faker::Commerce.product_name,
        sku: Faker::Alphanumeric.alpha(number: 10),
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

      scraped_variant = ScrapeProductVariantJob.new(product_variant).perform_now

      expect(scraped_variant[:name]).to be_a(String)
    end
  end
end
