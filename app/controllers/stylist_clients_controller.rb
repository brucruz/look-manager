class StylistClientsController < ApplicationController
  before_action :product_id_params

  def new
    @stylist_client = StylistClient.new
  end

  def create
    create_params = { stylist_id: current_user.id }.merge(stylist_client_params || {})

    @stylist_client = StylistClient.create(create_params)
    @product_id_params = product_id_params
    redirect_to product_path(product_id_params)
  end

  def current_user_clients
    @stylist_clients = StylistClient.where(stylist_id: current_user.id)
  end

  private

  def stylist_client_params
    params.require(:stylist_client).permit(
      :stylist_id,
      :name
    )
  end

  def product_id_params
    return unless params.require(:product).present?

    params.require(:product)
  end
end
