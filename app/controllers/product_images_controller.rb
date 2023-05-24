class ProductImagesController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    @product_image = @product.product_images.create(product_image_params)
    redirect_to product_path(@product)
  end

  private
    def product_image_params
      params.require(:product_image).permit(:image)
    end
end
