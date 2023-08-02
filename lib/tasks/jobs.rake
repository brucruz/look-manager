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
        sku: product.sku,
        url: product.url,
        description: product.description,
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

  desc "Run this script to treat past products to fix old data and differentiate from variant's data"
  task treat_existing_products_data: :environment do
    products_to_save = []

    ActiveRecord::Base.transaction do
      # oqvestir products
      puts "Preparing oqvestir.com.br products..."
      ## get all products
      puts "Getting all oqvestir products..."
      oqvestir_products = Product.where(store_url: "oqvestir.com.br").where.not(sku: nil)

      puts "Found #{oqvestir_products.count} oqvestir products"

      ## for each product, get the old sku, split with '_' and get the first part. e.g: '27.PI.1206_MARFIMFAI' turns into '27.PI.1206'
      for product in oqvestir_products do
        sku = product.sku.split('_')[0]
        name = product.name.split(' - ')[0]
        
        is_female = [product.name, product.description]
          .select {|i| i != nil}
          .any? { |text| text.downcase.include?('feminin') }
        is_male = [product.name, product.description]
          .select {|i| i != nil}
          .any? { |text| text.downcase.include?('masculin') }
        gender = is_female ? 'female' : is_male ? 'male' : nil

        products_to_save << {
          :id => product.id,
          :name => name,
          :sku => sku,
          :gender => gender,
        }
      end

      # offpremium products
      puts "Preparing offpremium.com.br products..."
      ## get all products
      puts "Getting all oqvestir products..."
      offpremium_products = Product.where(store_url: "offpremium.com.br").where.not(sku: nil)

      puts "Found #{offpremium_products.count} offpremium products"

      ## for each product, get the old sku, split with '_' and get the first part. e.g: '27.PI.1206_MARFIMFAI' turns into '27.PI.1206'
      for product in offpremium_products do
        sku = product.sku.split('_')[0]
        name = product.name.split(' - ')[0]
        
        is_female = [product.name, product.description]
          .select {|i| i != nil}
          .any? { |text| text.downcase.include?('feminin') }
        is_male = [product.name, product.description]
          .select {|i| i != nil}
          .any? { |text| text.downcase.include?('masculin') }
        gender = is_female ? 'female' : is_male ? 'male' : nil

        products_to_save << {
          :id => product.id,
          :name => name,
          :sku => sku,
          :gender => gender,
        }
      end

      # shop2gether products
      puts "Preparing shop2gether.com.br products..."
      ## get all products
      puts "Getting all oqvestir products..."
      shop2gether_products = Product.where(store_url: "shop2gether.com.br").where.not(sku: nil)

      puts "Found #{shop2gether_products.count} shop2gether products"

      ## for each product, get the old sku, split with '_' and get the first part. e.g: '27.PI.1206_MARFIMFAI' turns into '27.PI.1206'
      for product in shop2gether_products do
        sku = product.sku.split('_')[0]
        name = product.name.split(' - ')[0]
        
        is_female = [product.name, product.description]
          .select {|i| i != nil}
          .any? { |text| text.downcase.include?('feminin') }
        is_male = [product.name, product.description]
          .select {|i| i != nil}
          .any? { |text| text.downcase.include?('masculin') }
        gender = is_female ? 'female' : is_male ? 'male' : nil

        products_to_save << {
          :id => product.id,
          :name => name,
          :sku => sku,
          :gender => gender,
        }
      end

      # alaya products
      puts "Preparing alaya.com.br products..."
      ## get all products with skus
      puts "Getting all alaya products with skus..."
      alaya_products = Product.where(store_url: "alayabrand.com").where.not(sku: nil)

      puts "Found #{alaya_products.count} alaya products"

      ## for each product, get the old sku, split with '_' and get the first part. e.g: '27.PI.1206_MARFIMFAI' turns into '27.PI.1206'
      for product in alaya_products do
        name = product.name.split(' – ').first
        sku = product.sku.split('-').first
        gender = 'female'

        products_to_save << {
          :id => product.id,
          :name => name,
          :sku => sku,
          :gender => gender,
        }
      end

      # preparing products in indexes to save
      products_indexes_to_save = products_to_save.index_by { |product| product[:id] }

      ## save all the changed products
      puts "Saving all products..."
      Product.update(products_indexes_to_save.keys, products_indexes_to_save.values)

      puts "Updated #{products_indexes_to_save.count} products"
    end
  end

  desc "Run this script to merge products variants into a single product and delete the unused products"
  task merge_products: :environment do
    product_ids_to_delete = []

    ActiveRecord::Base.transaction do
      puts "Locating duplicated skus+store keys..."
      duplicated_keys = Product.select(:store, :sku).group(:store, :sku).having("count(*) > 1").size
      puts "Found #{duplicated_keys.count} duplicated products"

      puts "Starting to loop through duplicated keys to merge products..."
      duplicated_keys.each do |duplicated_key|
        key = duplicated_key.first
        count = duplicated_key.last
        store = key.first
        sku = key.last

        puts "Merging #{count} products with key #{key}..."
        product_ids_to_merge = Product.where(store: store, sku: sku).pluck(:id)

        first_product_id = product_ids_to_merge.first
        other_product_ids = product_ids_to_merge[1..-1]

        # update other_products product_variants id to first_product product_variants id
        ProductVariant.where(product_id: other_product_ids).update_all(product_id: first_product_id)

        product_ids_to_delete.push(*other_product_ids)
      end

      puts "Deleting #{product_ids_to_delete.count} products..."
      Product.where(id: product_ids_to_delete).delete_all
    end
  end

  desc "Run this script to set Products with variants containing 'masculin'/'feminin' in the description or full_name to male/female"
  task set_gender_based_on_description: :environment do
    ActiveRecord::Base.transaction do
      male_product_ids = []
      female_product_ids = []
      
      ## Product variants containing 'masculin' in the description or full_name, should have their product's gender set to 'male'
      ProductVariant.where('description ilike ?', '%masculin%')
        .or(ProductVariant.where('full_name ilike ?', '%masculin%')).each do |variant|
          product_id = variant.product_id
          male_product_ids << product_id
        end
  
      ## Product variants containing 'feminin' in the description or full_name, should have their product's gender set to 'male'
      ProductVariant.where('description ilike ?', '%feminin%')
        .or(ProductVariant.where('full_name ilike ?', '%feminin%')).each do |variant|
          product_id = variant.product_id
          female_product_ids << product_id
        end
  
      # remove duplicates from male_product_ids
      male_product_ids = male_product_ids.uniq
      
      # remove duplicates from female_product_ids
      female_product_ids = female_product_ids.uniq
  
      # update gender to male in all products with id equal to male_product_ids array AND (that gender is not 'male' OR that gender is not NULL)
      Product.where(id: male_product_ids).where('gender is null or gender <> ?', 'male').update_all(gender: 'male')

      # update gender to female in all products with id equal to female_product_ids array AND (that gender is not 'female' OR that gender is not NULL)
      Product.where(id: female_product_ids).where('gender is null or gender <> ?', 'female').update_all(gender: 'female')
    end
  end

  desc "Fix products and variants with no images"
  task fix_products_and_variants_with_no_images: :environment do
    ActiveRecord::Base.transaction do
      puts "Fixing variants with no images..."

      ProductVariant.where('images = ?', '{}').each do |variant|
        puts "Fixing variant #{variant.id}..."
        if variant.product.images.present? && variant.product.images.any?
          puts "Variant #{variant.id} has no images, but its product has images. Setting product images to variant images..."
          variant.images = variant.product.images
          variant.save!
          puts "Variant #{variant.id} fixed!"
          return
        end
      
        # destroy Product and ProductVariant if it has no images
        puts "Variant #{variant.id} has no images and its product has no images. Destroying variant and product..."
        product_id = variant.product.id
        variant.destroy
        Product.where(id: product_id).destroy_all
        puts "Variant #{variant.id} and product #{product_id} destroyed!"
      end
    end

    puts "Fixed variants with no images. There are #{ProductVariant.where('images = ?', '{}').count} variants with no images."
  end
end




# ProductVariant.where('title ilike ?', '% - %').map do |product|
#   # remove everything after the first ' - ', including the ' - '
#   product.name = product.name.split(' - ').first
#   product.save!
# end

# ProductVariant.where('title ilike ?', '% - %').where(ProductVariant.arel_table[:title].eq(ProductVariant.arel_table[:full_name])).map do |variant|
#   variant.title = variant.title.split(' - ').last.capitalize  
#   variant.save!
# end

# ActiveRecord::Base.transaction do
#   product_variants_to_save = []
#   product_variant_ids_to_destroy = []

#   ProductVariant.where(url: nil).each do |variant|
#     product = variant.product
#     product_variants = product.product_variants
    
#     # check if all of the product's product_variants doesn't have an url
#     if product_variants.all? { |variant| variant.url.nil?  }
#       product_variants_to_save.push(*product_variants.map { |variant| { :id => variant.id, :url => product.url } })
#     else
#       product_variant_ids_to_destroy.push(*product_variants.select { |variant| variant.url.nil?  }.map(&:id))
#     end
#   end

#   product_variants_to_save = product_variants_to_save.uniq

#   variant_indexes_to_save = product_variants_to_save.index_by { |variant| variant[:id] }
  
#   puts "Updating #{product_variants_to_save.count} product variants..."
#   ProductVariant.update(variant_indexes_to_save.keys, variant_indexes_to_save.values)

#   puts "Deleting #{product_variant_ids_to_destroy.count} product variants..."
#   ProductVariant.where(id: product_variant_ids_to_destroy).destroy_all
# end


# ActiveRecord::Base.transaction do
#   product_ids_with_equal_urls = []

#   Product.all.each do |product|
#     variant_urls = product.product_variants.map { |variant| variant.url }
#     variant_urls_count = variant_urls.uniq.count
#     puts "Product #{product.id} has #{variant_urls_count}/#{variant_urls.count} urls"
#     if variant_urls_count == 1 && variant_urls.count > 1
#       product_ids_with_equal_urls << product
#     end
#   end
#   puts "Total products: #{Product.count}"
#   puts "Total products with equal urls: #{product_ids_with_equal_urls.count}"
#   # Product.where(id: product_ids_with_equal_urls).destroy_all
# end