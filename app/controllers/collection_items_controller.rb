class CollectionItemsController < ApplicationController
  before_action :set_product, only: %i[ create new edit ]

  def create
    create_params = { user_id: current_user.id }.merge(collection_item_params || {})

    @collection_item = @product.collection_items.create(create_params)

    redirect_to product_path(@product)
  end

  def new
    @collection_item = @product.collection_items.new
  end

  def index
    @products = Product.joins(:collection_items).where('user_id = ?', current_user.id)
  end

  def edit
    @collection_item = CollectionItem.find(params[:id])
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
      body_type: []
    )
  end
end
