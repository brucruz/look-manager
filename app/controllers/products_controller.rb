class ProductsController < ApplicationController
  include Pagy::Backend

  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    if params[:search].present? && params[:search] != ''
      @pagy, @products = pagy((Product.search(params[:search])), items: 10)
      @count = Product.search(params[:search]).count
    else
      @pagy, @products = pagy((Product.all), items: 10)
      @count = Product.count
    end
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    # @product = Product.new
    @product_url = params[:product_url]
    return unless @product_url.present?

    @product = Product.find_by(url: @product_url)

    # If the product is already in the database, redirect to the result page and pass the product data
    if @product.present?
      redirect_to product_path(id: @product.id)
      return
    end

    # If the product is not on the database, start the scraping process
    scraper = Scrapers::ProductScraper.new(@product_url)
    scraped_product = scraper.scrape

    @product = Product.create(scraped_product)

    # Redirect to the result page and pass the scraped data
    redirect_to product_path(id: @product.id)
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to product_url(@product), notice: 'Product was successfully created.' }
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
        format.html { redirect_to product_url(@product), notice: 'Product was successfully updated.' }
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
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(
      :search,
      :name,
      :sku,
      :brand,
      :store,
      :url,
      :store_url,
      :description,
      :currency,
      :old_price,
      :price,
      :installment_quantity,
      :installment_value,
      :available,
      images: [],
      sizes: [],
    )
  end
end
