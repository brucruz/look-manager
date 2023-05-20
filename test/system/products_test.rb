require "application_system_test_case"

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:one)
  end

  test "visiting the index" do
    visit products_url
    assert_selector "h1", text: "Products"
  end

  test "should create product" do
    visit products_url
    click_on "New product"

    check "Available" if @product.available
    fill_in "Brand", with: @product.brand
    fill_in "Description", with: @product.description
    fill_in "Installment quantity", with: @product.installment_quantity
    fill_in "Installment value", with: @product.installment_value
    fill_in "Name", with: @product.name
    fill_in "Old price", with: @product.old_price
    fill_in "Price", with: @product.price
    fill_in "Sku", with: @product.sku
    fill_in "Store", with: @product.store
    fill_in "Store url", with: @product.store_url
    fill_in "Url", with: @product.url
    click_on "Create Product"

    assert_text "Product was successfully created"
    click_on "Back"
  end

  test "should update Product" do
    visit product_url(@product)
    click_on "Edit this product", match: :first

    check "Available" if @product.available
    fill_in "Brand", with: @product.brand
    fill_in "Description", with: @product.description
    fill_in "Installment quantity", with: @product.installment_quantity
    fill_in "Installment value", with: @product.installment_value
    fill_in "Name", with: @product.name
    fill_in "Old price", with: @product.old_price
    fill_in "Price", with: @product.price
    fill_in "Sku", with: @product.sku
    fill_in "Store", with: @product.store
    fill_in "Store url", with: @product.store_url
    fill_in "Url", with: @product.url
    click_on "Update Product"

    assert_text "Product was successfully updated"
    click_on "Back"
  end

  test "should destroy Product" do
    visit product_url(@product)
    click_on "Destroy this product", match: :first

    assert_text "Product was successfully destroyed"
  end
end
