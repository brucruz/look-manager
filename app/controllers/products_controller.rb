class ProductsController < ApplicationController
  include Pagy::Backend

  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    items_per_page = 24

    # TODO: make this not-male filter dynamic and add other filters
    if params[:search].present? && params[:search] != ''
      @pagy, @products = pagy((Product.search(params[:search])
        .joins(:product_variants)
        .where(:product_variants => { :deleted_source => false })
        .where.not(gender: 'male')
        .or(Product.where('gender is null'))
        ), items: items_per_page)
      @count = Product.search(params[:search])
        .joins(:product_variants)
        .where(:product_variants => { :deleted_source => false })
        .where.not(gender: 'male')
        .or(Product.where('gender is null'))
        .count
    else
      @pagy, @products = pagy((Product
          .joins(:product_variants)
          .where(:product_variants => { :deleted_source => false })
          .where.not(gender: 'male')
          .or(Product.where('gender is null'))
          ), items: items_per_page)
      @count = Product
        .joins(:product_variants)
        .where(:product_variants => { :deleted_source => false })
        .where.not(gender: 'male')
        .or(Product.where('gender is null'))
        .count
    end
  end

  # GET /products/1 or /products/1.json
  def show
    id = params[:id]
    variant_title = params[:variant]
    @product = Product.find(id)
    
    if variant_title.present?
      @variant = ProductVariant.find_by(product_id: id, title: variant_title)
    else
      @variant = @product.product_variants.first
    end

    return @product, @variant
  end

  # GET /products/new
  def new
    # @product = Product.new
    @product_url = params[:product_url]
    return unless @product_url.present?

    @variant = ProductVariant.find_by(url: @product_url)
    @product = @variant.product if @variant.present?

    # If the product is already in the database, redirect to the result page and pass the product data
    if @product.present?
      redirect_to product_path(id: @product.id)
      return
    end

    # If the product is not on the database, start the scraping process
    scraper = Scrapers::ProductScraper.new(@product_url)
    scraped_product, scraped_variants = scraper.scrape

    ActiveRecord::Base.transaction do
      # check if the product is already in the database
      @product = Product.find_by(
        store: scraped_product["store"],
        sku: scraped_product["sku"]
      )
      
      @product = Product.create(scraped_product) if @product.nil?
      
      for variant in scraped_variants
        variant[:product_id] = @product.id
        ProductVariant.create(variant)
      end
    end


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
      :gender,
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
