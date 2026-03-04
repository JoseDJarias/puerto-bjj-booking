module Admin
  class MembershipPricingsController < BaseController
    before_action :set_pricing, only: %i[edit update destroy]

    def index
      @pricings = MembershipPricing.includes(:membership_package, :membership_plan)
                                   .order("membership_packages.name, membership_plans.duration_months")
    end

    def new
      @pricing = MembershipPricing.new
    end

    def create
      @pricing = MembershipPricing.new(pricing_params)
      if @pricing.save
        redirect_to admin_membership_pricings_path, notice: t("admin.membership_pricings.flash.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @pricing.update(pricing_params)
        redirect_to admin_membership_pricings_path, notice: t("admin.membership_pricings.flash.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @pricing.destroy
      redirect_to admin_membership_pricings_path, notice: t("admin.membership_pricings.flash.destroyed"), status: :see_other
    end

    private

    def set_pricing
      @pricing = MembershipPricing.find(params[:id])
    end

    def pricing_params
      params.require(:membership_pricing).permit(:membership_package_id, :membership_plan_id, :price)
    end
  end
end