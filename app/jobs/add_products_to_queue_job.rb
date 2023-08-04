class AddProductsToQueueJob < ApplicationJob
  queue_as :default

  def perform(*args)
    variants = ProductVariant.all
    puts("Adding #{variants.count} product variants to queue")

    # add each product to the queue of ScrapeProductVariantJob passing product as an argument
    variants.each do |variant|
      ScrapeProductVariantJob.perform_later(variant)
      puts("Product variant #{variant.full_name} added to queue")
    end
  end
end
