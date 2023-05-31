class CollectionItemsController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    @collection_item = @product.collection_items.create({ user_id: current_user.id, **collection_item_params })
    redirect_to product_path(@product)
  end
  
  private
    def collection_item_params
      params.require(:collection_item).permit(
        :user_id,
        :category,
        :color,
        :palette,
        :contrast,
        :style,
        :body_type
      )
    end
end
