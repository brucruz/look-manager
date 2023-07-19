namespace :jobs do
  desc "Run this script to remove duplicate ScrapeProductUrlJobs (with the same url)"
  task clear_scrape_product_url_duplicates: :environment do
    puts "Removing duplicate ScrapeProductUrlJobs (with the same url)..."

    result = ActiveRecord::Base.connection.execute("
      delete from good_jobs
      where serialized_params->>'arguments' IN (
        select serialized_params->>'arguments'
        from good_jobs
        where job_class = 'ScrapeProductUrlJob' and performed_at is null
        group by serialized_params->>'arguments'
        having count(serialized_params->>'arguments') > 1
      )")

    if result.cmd_tuples > 0
      puts "Removed #{result.cmd_tuples} duplicate ScrapeProductUrlJobs (with the same url)"
    else
      puts "No duplicate ScrapeProductUrlJobs (with the same url) found"
    end
  end

  desc "Run this script to get data from old products and move it to product variants"
  task move_old_product_data_to_product_variants: :environment do
    # get all products without variants
    puts "Getting all products without variants..."

    products_without_variants = Product.where.not(id: ProductVariant.select(:product_id).distinct)

    puts "Found #{products_without_variants.count} products without variants"

    # for each product, get the old data (name, currency, images, old_price, price, installment_quantity, installment_value, available, sizes) and create a variant
    for product in products_without_variants
      puts "Creating variant for product #{product.id}..."

      variant = ProductVariant.new(
        title: product.name,
        full_name: product.name,
        currency: product.currency,
        images: product.images,
        old_price: product.old_price,
        price: product.price,
        installment_quantity: product.installment_quantity,
        installment_value: product.installment_value,
        available: product.available,
        sizes: product.sizes,
        product_id: product.id,
      )

      variant.save!

      puts "Variant created for product #{product.id}"
    end
  end
end
