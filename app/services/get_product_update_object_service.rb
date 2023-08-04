## it receives a product object and a hash with the new attributes, then it updates the product and returns it
class GetProductUpdateObjectService
  def initialize(initial_product_object, new_object_attributes)
    @old_object_attributes = get_params(initial_product_object)
    @new_object_attributes = get_params(new_object_attributes)
    @product_id = initial_product_object["product"][:id]
  end

  def call
    product_to_update = {}
    variant_to_update = {}

    product_to_update = @new_object_attributes["product"]
    variants_to_update = @new_object_attributes["variants"]

    # treating product attributes
    if product_to_update["sku"].nil?
      product_to_update["sku"] = @old_object_attributes["product"]["sku"]
    end
    if product_to_update["brand"].nil?
      product_to_update["brand"] = @old_object_attributes["product"]["brand"]
    end

    # treating variant attributes
    variants_to_update.map.with_index do |variant_to_update, index|
      new_variant_attributes = @new_object_attributes["variants"][index]
      old_variant_attributes = @old_object_attributes["variants"][index]

      # if new name, sku, brand, description, images and sizes attributes are missing use the old product attributes
      if new_variant_attributes["title"].nil?
        variant_to_update["title"] = old_variant_attributes["title"]
      end
      if new_variant_attributes["full_name"].nil?
        variant_to_update["full_name"] = old_variant_attributes["full_name"]
      end
      if new_variant_attributes["sku"].nil?
        variant_to_update["sku"] = old_variant_attributes["sku"]
      end
      if new_variant_attributes["description"].nil?
        variant_to_update["description"] = old_variant_attributes["description"]
      end
      if new_variant_attributes["images"].nil? || new_variant_attributes["images"].empty?
        variant_to_update["images"] = old_variant_attributes["images"]
      end
      if new_variant_attributes["sizes"].nil? || new_variant_attributes["sizes"].empty?
        variant_to_update["sizes"] = old_variant_attributes["sizes"]
      end
  
      # if both old_price and price attributes are missing use the old product attributes
      if new_variant_attributes["old_price"].nil? && new_variant_attributes["price"].nil?
        variant_to_update["old_price"] = old_variant_attributes["old_price"]
        variant_to_update["price"] = old_variant_attributes["price"]
      end
  
      # if installment quantity or value is missing...
      if [new_variant_attributes["installment_quantity"], new_variant_attributes["installment_value"]].any?(&:nil?)
        # check first if both installment_quantity and installment_value attributes are missing...
        if new_variant_attributes["installment_quantity"].nil? && new_variant_attributes["installment_value"].nil?
          ## check if price is also missing...
          if new_variant_attributes["price"].nil?
            ## if it is missing, then return old attributes
            variant_to_update["installment_quantity"] = old_variant_attributes["installment_quantity"]
            variant_to_update["installment_value"] = old_variant_attributes["installment_value"]
          else
            ## return new attributes
            variant_to_update["installment_quantity"] = new_variant_attributes["installment_quantity"]
            variant_to_update["installment_value"] = new_variant_attributes["installment_value"]
          end
        else
          # if only one of them is nil, then use the old attributes
          variant_to_update["installment_quantity"] = old_variant_attributes["installment_quantity"]
          variant_to_update["installment_value"] = old_variant_attributes["installment_value"]
        end
      end

      # if price is missing, use the previous old_price and price attributes
      if new_variant_attributes["price"].nil?
        variant_to_update["old_price"] = old_variant_attributes["old_price"]
        variant_to_update["price"] = old_variant_attributes["price"]
      end

      variant_to_update["product_id"] = @product_id
      variant_to_update["updated_at"] = Time.now

      variant_to_update
    end
    

    # set updated_at attribute as now
    product_to_update["updated_at"] = Time.now
    
    product_to_update

    return {
      "product" => product_to_update,
      "variants" => variants_to_update
    }
  end

  def get_params(object)
    product_params = {}

    if object["product"].is_a?(Hash)
      object["product"] = Product.new(object["product"])
    end

    product_params = {
      **object["product"].slice(
        :sku,
        :brand
      )
    }

    variants_params = []

    object["variants"].each do |variant|
      if variant.is_a?(Hash)
        variant = ProductVariant.new(variant)
      end

      variant_params = variant.slice(
        :title,
        :full_name,
        :sku,
        :description,
        :available,
        :url,
        :images,
        :sizes,
        :old_price,
        :price,
        :installment_quantity,
        :installment_value
      )

      variants_params << variant_params
    end


    return {
      "product" => product_params,
      "variants" => variants_params
    }
  end
end