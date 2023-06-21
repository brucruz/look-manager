## it receives a product object and a hash with the new attributes, then it updates the product and returns it
class GetProductUpdateObjectService
  def initialize(product, new_attributes)
    @old_attributes = product.slice(
      :name, 
      :sku, 
      :brand, 
      :description, 
      :images, 
      :sizes, 
      :old_price, 
      :price, 
      :installment_quantity, 
      :installment_value
    )
    @new_attributes = new_attributes
  end

  def call
    product_to_update = {}
    product_to_update = { **@new_attributes }

    # if new name, sku, brand, description, images and sizes attributes are missing use the old product attributes
    if @new_attributes[:name].nil?
      product_to_update[:name] = @old_attributes[:name]
    end
    if @new_attributes[:sku].nil?
      product_to_update[:sku] = @old_attributes[:sku]
    end
    if @new_attributes[:brand].nil?
      product_to_update[:brand] = @old_attributes[:brand]
    end
    if @new_attributes[:description].nil?
      product_to_update[:description] = @old_attributes[:description]
    end
    if @new_attributes[:images].nil? || @new_attributes[:images].empty?
      product_to_update[:images] = @old_attributes[:images]
    end
    if @new_attributes[:sizes].nil? || @new_attributes[:sizes].empty?
      product_to_update[:sizes] = @old_attributes[:sizes]
    end

    # if both old_price and price attributes are missing use the old product attributes
    if @new_attributes[:old_price].nil? && @new_attributes[:price].nil?
      product_to_update[:old_price] = @old_attributes[:old_price]
      product_to_update[:price] = @old_attributes[:price]
    end

    # if price is missing, use the previous old_price and price attributes
    if @new_attributes[:price].nil?
      product_to_update[:old_price] = @old_attributes[:old_price]
      product_to_update[:price] = @old_attributes[:price]
    end

    
    # if installment quantity or value is missing...
    if [@new_attributes[:installment_quantity], @new_attributes[:installment_value]].any?(&:nil?)
      # check first if both installment_quantity and installment_value attributes are missing...
      if @new_attributes[:installment_quantity].nil? && @new_attributes[:installment_value].nil?
        ## check if price is also missing...
        if @new_attributes[:price].nil?
          ## if it is missing, then return old attributes
          product_to_update[:installment_quantity] = @old_attributes[:installment_quantity]
          product_to_update[:installment_value] = @old_attributes[:installment_value]
        else
          ## return new attributes
          product_to_update[:installment_quantity] = @new_attributes[:installment_quantity]
          product_to_update[:installment_value] = @new_attributes[:installment_value]
        end
      else
        # if only one of them is nil, then use the old attributes
        product_to_update[:installment_quantity] = @old_attributes[:installment_quantity]
        product_to_update[:installment_value] = @old_attributes[:installment_value]
      end
    end
    
    product_to_update
  end
end