class ProductsController < ApplicationController
  def index
    @products = Product.with_attached_images.active.recent
  end

  def show
    @product = Product.active.find(params[:id])
  end
end
