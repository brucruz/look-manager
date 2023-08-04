require 'rails_helper'

RSpec.describe GetProductUpdateObjectService,
type: :model do
  context "When testing the GetProductUpdateObjectService class" do
    before :each do
      sizes = [
        {
          size: "p",
          available: true,
          url: Faker::Internet.url,
        },
       
        {
          size: "m",
          available: false,
          url: Faker::Internet.url,
        },
       
        {
          size: "g",
          available: false,
          url: Faker::Internet.url,
        },
       
        {
          size: "gg",
          available: true,
          url: Faker::Internet.url,
        },
       
        {
          size: "xg",
          available: true,
          url: Faker::Internet.url,
        }
      ]

      product_id = 1

      @initial_product = Product.new(
        id: product_id,
        sku: "123456",
        brand: "Brand 1",
        store: 'store 1',
        store_url: 'https://store_url_1.com',        
      )
      
      @initial_variant = ProductVariant.new(
        title: "Product 1",
        full_name: "Product 1 - White",
        sku: "123456_WHITE",
        description: "Description 1",
        images: ["image1.jpg", "image2.jpg"],
        sizes: sizes,
        available: true,
        url: Faker::Internet.url,
        old_price: 100.00,
        price: 90.00,
        installment_quantity: 5,
        installment_value: 18.00
      )

      @initial_product_object = {
        "product" => @initial_product,
        "variants" => [@initial_variant],
      }

      @old_product_attributes = @initial_product.slice(
        :sku, 
        :brand,
      )

      @old_variant_attributes = @initial_variant.slice(
        :title, 
        :full_name, 
        :sku, 
        :description, 
        :images, 
        :sizes, 
        :available,
        :url,
        :old_price, 
        :price, 
        :installment_quantity, 
        :installment_value
      )

      @old_object_attributes = {
        "product" => @old_product_attributes,
        "variants" => [@old_variant_attributes],
      }

      @new_product = {
        sku: "654321",
        brand: "Brand 2",
        store: 'store 2',
        store_url: 'https://store_url_2.com',
      }

      @new_variant = {
        title: "Product 2",
        full_name: "Product 2 - Black",
        sku: "654321_BLACK",
        brand: "Brand 2",
        description: "Description 2",
        images: ["image3.jpg", "image4.jpg"],
        sizes: sizes,
        available: true,
        url: Faker::Internet.url,
        old_price: 110.00,
        price: 99.00,
        installment_quantity: 10,
        installment_value: 9.90
      }

      @new_product_attributes = @new_product.slice(
        :sku, 
        :brand,
      )

      @new_variant_attributes = @new_variant.slice(
        :title, 
        :full_name, 
        :sku, 
        :description, 
        :images, 
        :sizes, 
        :available,
        :url,
        :old_price, 
        :price, 
        :installment_quantity, 
        :installment_value
      )

      @new_object_attributes = {
        "product" => @new_product_attributes,
        "variants" => [@new_variant_attributes],
      }
    end

    it "should return a object equal to new_attributes if it is just a slice of @initial_product", focus: true do
      new_attributes_equal_to_old_attributes = @old_object_attributes
      update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes_equal_to_old_attributes).call
      debugger
      expect(update_object).to eq(@old_object_attributes)
    end

    it "should return a object equal to new_attributes all its attribues are not nil" do
      update_object = GetProductUpdateObjectService.new(@initial_product_object, @new_object_attributes).call
      expect(update_object).to eq(@new_object_attributes)
    end

    it "should return old attributes if new name, sku, brand, description, images and sizes attributes are missing" do
      new_attributes = @new__object_attributes

      new_attributes["product"][:brand] = nil
      new_attributes["product"][:sku] = nil

      new_attributes["variants"][0][:title] = nil
      new_attributes["variants"][0][:full_name] = nil
      new_attributes["variants"][0][:sku] = nil
      new_attributes["variants"][0][:description] = nil
      new_attributes["variants"][0][:images] = []
      new_attributes["variants"][0][:sizes] = []
      
      update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes).call
      update_product = update_object["product"]
      update_variant = update_object["variants"][0]
      
      expect(update_product[:sku]).to eq(@initial_product.sku)
      expect(update_product[:brand]).to eq(@initial_product.brand)

      expect(update_variant[:title]).to eq(@initial_variant.title)
      expect(update_variant[:full_name]).to eq(@initial_variant.full_name)
      expect(update_variant[:sku]).to eq(@initial_variant.sku)
      expect(update_variant[:description]).to eq(@initial_variant.description)
      expect(update_variant[:images]).to eq(@initial_variant.images)
      expect(update_variant[:sizes]).to eq(@initial_variant.sizes)
    end

    context "price and old_price update" do
      it "should return new price attributes if both old_price and price attributes are present" do
        update_object = GetProductUpdateObjectService.new(@initial_product_object, @new_object_attributes).call

        update_variant = update_object["variants"][0]
        
        expect(update_variant[:old_price]).to eq(@new_variant_attributes[:old_price])
        expect(update_variant[:price]).to eq(@new_variant_attributes[:price])
      end

      it "should return use the old prices attributes if both old_price and price attributes are missing" do
        new_attributes = @new_object_attributes
        new_attributes["variants"][0][:old_price] = nil
        new_attributes["variants"][0][:price] = nil
        
        update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes).call
        update_variant = update_object["variants"][0]
        
        expect(update_variant[:old_price]).to eq(@initial_variant.old_price)
        expect(update_variant[:price]).to eq(@initial_variant.price)
      end

      it "should return the new price attributes if only old_price is missing" do
        new_attributes = @new_object_attributes
        new_attributes["variants"][0][:old_price] = nil

        update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes).call
        update_variant = update_object["variants"][0]

        expect(update_variant[:old_price]).to eq(nil)
        expect(update_variant[:price]).to eq(new_attributes["variants"][0][:price])
      end

      it "should return the old price attributes only price is missing" do
        new_attributes = @new_object_attributes
        new_attributes["variants"][0][:price] = nil

        update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes).call
        update_variant = update_object["variants"][0]

        expect(update_variant[:old_price]).to eq(@old_variant_attributes[:old_price])
        expect(update_variant[:price]).to eq(@old_variant_attributes[:price])
      end
    end

    context "installment_quantity and installment_value update" do
      it "should return new installments quantity and value attributes if both are present" do
        update_object = GetProductUpdateObjectService.new(@initial_product_object, @new_object_attributes).call
        update_variant = update_object["variants"][0]

        expect(update_variant[:installment_quantity]).to eq(@new_variant_attributes[:installment_quantity])
        expect(update_variant[:installment_value]).to eq(@new_variant_attributes[:installment_value])
      end

      it "should return new installments quantity and value attributes if both are missing AND price is present" do
        new_attributes = @new_object_attributes
        new_attributes["variants"][0][:installment_quantity] = nil
        new_attributes["variants"][0][:installment_value] = nil
        new_attributes["variants"][0][:price] = 100.00

        update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes).call
        update_variant = update_object["variants"][0]

        expect(update_variant[:installment_quantity]).to eq(@new_variant_attributes[:installment_quantity])
        expect(update_variant[:installment_value]).to eq(@new_variant_attributes[:installment_value])
      end

      it "should return OLD installments quantity and value attributes if both are missing AND price is NOT present" do
        new_attributes = @new_object_attributes
        new_attributes["variants"][0][:installment_quantity] = nil
        new_attributes["variants"][0][:installment_value] = nil
        new_attributes["variants"][0][:price] = nil

        update_object = GetProductUpdateObjectService.new(@initial_product_object, new_attributes).call
        update_variant = update_object["variants"][0]

        expect(update_variant[:installment_quantity]).to eq(@old_variant_attributes[:installment_quantity])
        expect(update_variant[:installment_value]).to eq(@old_variant_attributes[:installment_value])
      end
    end
  end
end