module Admin
  class MembershipPlansController < BaseController

    before_action :set_membership_plan, only: %i[edit update]

    def index
      @membership_plans = MembershipPlan.order(:duration_months)
    end

    def new
      @membership_plan = MembershipPlan.new
    end

    def create
      @membership_plan = MembershipPlan.new(membership_plan_params)
      if @membership_plan.save
        redirect_to admin_membership_plans_path, notice: t('admin.plans.flash.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @membership_plan.update(membership_plan_params)
        redirect_to admin_membership_plans_path, notice: t('admin.plans.flash.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_membership_plan
      @membership_plan = MembershipPlan.find(params[:id])
    end

    def membership_plan_params
      params.require(:membership_plan).permit(:name, :duration_months, :price, :active)
    end
  end
end
