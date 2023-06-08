class CollectionItemsController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    
    create_params = { user_id: current_user.id }.merge(collection_item_params&.to_h || {})

    @collection_item = @product.collection_items.create(create_params)
    
    redirect_to product_path(@product)
  end
  
  private
    def collection_item_params
      params.require(:collection_item).permit(
        :user_id,
        # :category,
        # :color,
        palette: [],
        contrast: [],
        style: [],
        body_type: []
      ) if params[:collection_item].present?
    end
end
