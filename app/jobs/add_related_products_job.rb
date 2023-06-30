class AddRelatedProductsJob < ApplicationJob
  queue_as :default

  def perform(related_products)
    if related_products.blank?
      return
    end

    new_urls = ApplicationController.helpers.get_new_urls(related_products)


    puts "Creating #{new_urls.count} new products jobs"
    new_urls.each do |url|
      ScrapeProductUrlJob.perform_later(url)
      puts "Created job for #{url}"
    end

    puts "Done creating jobs"
  end
end