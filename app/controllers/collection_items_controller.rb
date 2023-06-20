class CollectionItemsController < ApplicationController
  before_action :set_product, only: %i[ create new edit update ]

  def create
    create_params = { user_id: current_user.id }.merge(collection_item_params || {})

    @collection_item = @product.collection_items.create(create_params)

    redirect_to product_path(@product)
  end

  def new
    @collection_item = @product.collection_items.new
    @clients = StylistClient.where(stylist_id: current_user.id)
  end

  def index
    @products = Product.joins(:collection_items).where('user_id = ?', current_user.id)
  end

  def edit
    @collection_item = CollectionItem.find(params[:id])
    @clients = StylistClient.where(stylist_id: current_user.id)
  end

  def update
    @collection_item = CollectionItem.find(params[:id])

    respond_to do |format|
      if @collection_item.update(collection_item_params)
        format.html { redirect_to product_path(@product), notice: 'Collection Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def collection_item_params
    return unless params[:collection_item].present?

    params.require(:collection_item).permit(
      :user_id,
      # :category,
      # :color,
      palette: [],
      contrast: [],
      style: [],
      body_type: [],
      clients: []
    )
  end
end
