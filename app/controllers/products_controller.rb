require 'tanakai'

    # Create a new Tanakai scraper
    class ProductScraper < Tanakai::Base
      @name = 'product_scraper'
      @engine = :selenium_chrome
      @@scraped_product = {}

      def self.process(url)
        @start_urls = [url]
        self.crawl!
      end

      def self.scraped_product
        @@scraped_product
      end

      def parse(response, url:, data: {})
        # Scrape the product information using CSS selectors
        product_div = response.css('.product-essential')

        @@scraped_product[:name] = product_div.css('.produt-title--name').text.strip
        @@scraped_product[:sku] = product_div.css('.product--sku').text.strip
        @@scraped_product[:brand] = product_div.css('.produt-title--brand a').text.strip
        @@scraped_product[:description] = product_div.css('.stylesTips .panel-body').text.strip
        
        @@scraped_product[:old_price] = product_div.css('.product-price span.price[id^=old]').text.strip.gsub(/[^\d,]/, '').gsub(',', '.').to_f
        @@scraped_product[:price] = product_div.css('.product-price span.price[id^=product]').text.strip.gsub(/[^\d,]/, '').gsub(',', '.').to_f

        installment_value = product_div.css('.product-price .product-installment').text.strip.split("x de ")[1].strip
        @@scraped_product[:currency] = installment_value.scan(/[A-Z]{1}\$/).first
        @@scraped_product[:installment_value] = installment_value.gsub(/[^\d,]/, '').gsub(',', '.').to_f
        @@scraped_product[:installment_quantity] = product_div.css('.product-price .product-installment').text.strip.split("x de ")[0].to_i

        available = product_div.attr('class')
        @@scraped_product[:available] = available ? !available.include?('out-of-stock') : false

        @@scraped_product[:url] = url
        @@scraped_product[:store_url] = "https://oqvestir.com.br"
        @@scraped_product[:store] = "OQVestir"

        images = product_div.css(".slick-cloned img").map do |img|
          img.attr("src")
        end

        # sizes = product_div.css('#attribute185 option')
        #   .filter(function () {
        #     return $(this).attr("data-label") !== undefined;
        #   })
        #   .map(function () {
        #     size = $(this).attr("data-label") || "not-found";
            available = !$(this).attr("class")?.includes

        # Add the scraped product to the database
        @product = Product.create(@@scraped_product)

        @@scraped_product[:id] = @product.id

        # Add the scraped product images to the database
        images.each do |image|
          @product.product_images.create(url: image)
        end

        @@scraped_product
      end
    end

class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  def search
    @product_url = params[:product_url]
    return unless @product_url.present?

    @product = Product.find_by(url: @product_url)

    # If the product is already in the database, redirect to the result page and pass the product data
    if @product.present?
      redirect_to product_result_path(id: @product.id)
      return
    end

     # If the product is not on the database, start the scraping process
     ProductScraper.process(@product_url)
     
     scraped_product = ProductScraper.scraped_product

     # Redirect to the result page and pass the scraped data
    #  redirect_to product_result_path(scraped_product: scraped_product)
     redirect_to product_result_path(id: scraped_product[:id])
  end

  def result
    # @scraped_product = params[:scraped_product]
    @product = Product.find(params[:id])
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :sku, :brand, :store, :url, :store_url, :description, :currency, :old_price, :price, :installment_quantity, :installment_value, :available)
    end
end
