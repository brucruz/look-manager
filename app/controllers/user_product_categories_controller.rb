class UserProductCategoriesController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    @user_product_category = @product.user_product_categories.create({ user_id: current_user.id, **user_product_category_params })
    redirect_to product_path(@product)
  end
  
  private
    def user_product_category_params
      params.require(:user_product_category).permit(
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
