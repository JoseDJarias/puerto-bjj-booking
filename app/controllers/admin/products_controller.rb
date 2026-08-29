module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[show edit update destroy destroy_image]

    def index
      @products = Product.with_attached_images.recent
    end

    def show
    end

    def new
      @product = Product.new
    end

    def edit
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_products_path, notice: t("admin.products.create.success")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      # Append new images if provided, otherwise preserve existing
      if params[:product][:images].present?
        @product.images.attach(params[:product][:images])
      end

      if @product.update(product_params.except(:images))
        redirect_to admin_products_path, notice: t("admin.products.update.success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.destroy
        redirect_to admin_products_path, notice: t("admin.products.destroy.success")
      else
        redirect_to admin_products_path, alert: t("admin.products.destroy.error")
      end
    end

    # Remove an individual image from a product
    def destroy_image
      image = @product.images.find(params[:image_id])
      image.purge_later
      redirect_to edit_admin_product_path(@product), notice: t("admin.products.images.destroyed")
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name,
        :description,
        :price,
        :deposit_percentage,
        :notes,
        :category,
        :active,
        images: []
      )
    end
  end
end
