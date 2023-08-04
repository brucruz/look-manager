class AddRelatedProductsJob < ApplicationJob
  queue_as :default

  def perform(related_product_urls)
    if related_product_urls.blank?
      return
    end

    new_urls = ApplicationController.helpers.get_new_urls_from_product_variants(related_product_urls)


    puts "Creating #{new_urls.count} new products jobs"
    new_urls.each do |url|
      ScrapeProductVariantUrlJob.perform_later(url)
      puts "Created job for #{url}"
    end

    puts "Done creating jobs"
  end
end