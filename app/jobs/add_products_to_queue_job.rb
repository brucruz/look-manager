class AddProductsToQueueJob < ApplicationJob
  queue_as :default

  def perform(*args)
    products = Product.all
    puts("Adding #{products.count} products to queue")

    # add each product to the queue of ScrapeProductJob passing product as an argument
    products.each do |product|
      ScrapeProductJob.perform_later(product)
      puts("Product #{product.name} added to queue")
    end
  end
end
