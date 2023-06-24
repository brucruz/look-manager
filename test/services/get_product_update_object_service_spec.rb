require 'rails_helper'

RSpec.describe GetProductUpdateObjectService,
type: :model do
  context "When testing the GetProductUpdateObjectService class" do
    before :each do
      @initial_product = Product.new(
        name: "Product 1",
        sku: "123456",
        brand: "Brand 1",
        description: "Description 1",
        images: ["image1.jpg", "image2.jpg"],
        sizes: ["S", "M", "L"],
        old_price: 100.00,
        price: 90.00,
        installment_quantity: 5,
        installment_value: 18.00
      )

      @old_attributes = @initial_product.slice(
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

      @new_attributes = {
        name: "Product 2",
        sku: "654321",
        brand: "Brand 2",
        description: "Description 2",
        images: ["image3.jpg", "image4.jpg"],
        sizes: ["S", "M", "L"],
        old_price: 100.00,
        price: 90.00,
        installment_quantity: 5,
        installment_value: 18.00
      }
    end

    it "should return a object equal to new_attributes if it is just a slice of @initial_product" do
      new_attributes_equal_to_old_attributes = @old_attributes
      update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes_equal_to_old_attributes).call
      expect(update_object).to eq(@old_attributes)
    end

    it "should return a object equal to new_attributes all its attribues are not nil" do
      update_object = GetProductUpdateObjectService.new(@initial_product, @new_attributes).call
      expect(update_object).to eq(@new_attributes)
    end

    it "should return old attributes if new name, sku, brand, description, images and sizes attributes are missing" do
      new_attributes = @new_attributes
      new_attributes[:name] = nil
      new_attributes[:sku] = nil
      new_attributes[:brand] = nil
      new_attributes[:description] = nil
      new_attributes[:images] = []
      new_attributes[:sizes] = []
      
      update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes).call
      
      expect(update_object[:name]).to eq(@initial_product.name)
      expect(update_object[:sku]).to eq(@initial_product.sku)
      expect(update_object[:brand]).to eq(@initial_product.brand)
      expect(update_object[:description]).to eq(@initial_product.description)
      expect(update_object[:images]).to eq(@initial_product.images)
      expect(update_object[:sizes]).to eq(@initial_product.sizes)
    end

    context "price and old_price update" do
      it "should return new price attributes if both old_price and price attributes are present" do
        update_object = GetProductUpdateObjectService.new(@initial_product, @new_attributes).call
        
        expect(update_object[:old_price]).to eq(@new_attributes[:old_price])
        expect(update_object[:price]).to eq(@new_attributes[:price])
      end

      it "should return use the old prices attributes if both old_price and price attributes are missing" do
        new_attributes = @new_attributes
        new_attributes[:old_price] = nil
        new_attributes[:price] = nil
        
        update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes).call
        
        expect(update_object[:old_price]).to eq(@initial_product.old_price)
        expect(update_object[:price]).to eq(@initial_product.price)
      end

      it "should return the new price attributes if only old_price is missing" do
        new_attributes = @new_attributes
        new_attributes[:old_price] = nil

        update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes).call

        expect(update_object[:old_price]).to eq(nil)
        expect(update_object[:price]).to eq(new_attributes[:price])
      end

      it "should return the old price attributes only price is missing" do
        new_attributes = @new_attributes
        new_attributes[:price] = nil

        update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes).call

        expect(update_object[:old_price]).to eq(@old_attributes[:old_price])
        expect(update_object[:price]).to eq(@old_attributes[:price])
      end
    end

    context "installment_quantity and installment_value update" do
      it "should return new installments quantity and value attributes if both are present" do
        update_object = GetProductUpdateObjectService.new(@initial_product, @new_attributes).call

        expect(update_object[:installment_quantity]).to eq(@new_attributes[:installment_quantity])
        expect(update_object[:installment_value]).to eq(@new_attributes[:installment_value])
      end

      it "should return new installments quantity and value attributes if both are missing AND price is present" do
        new_attributes = @new_attributes
        new_attributes[:installment_quantity] = nil
        new_attributes[:installment_value] = nil
        new_attributes[:price] = 100.00

        update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes).call

        expect(update_object[:installment_quantity]).to eq(@new_attributes[:installment_quantity])
        expect(update_object[:installment_value]).to eq(@new_attributes[:installment_value])
      end

      it "should return OLD installments quantity and value attributes if both are missing AND price is NOT present", focus: true do
        new_attributes = @new_attributes
        new_attributes[:installment_quantity] = nil
        new_attributes[:installment_value] = nil
        new_attributes[:price] = nil

        update_object = GetProductUpdateObjectService.new(@initial_product, new_attributes).call

        expect(update_object[:installment_quantity]).to eq(@old_attributes[:installment_quantity])
        expect(update_object[:installment_value]).to eq(@old_attributes[:installment_value])
      end
    end
  end
end