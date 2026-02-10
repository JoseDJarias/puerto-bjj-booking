module Admin
  class MembershipsController < BaseController
    before_action :set_membership, only: %i[edit update destroy]
    before_action :set_collections, only: %i[new create edit update]

    def index
      @memberships = Membership.includes(:user, :membership_plan, :membership_package)
                               .order(created_at: :desc)
    end

    def new
      @membership = Membership.new(start_date: Date.current)
      
      # Handle pre-selection from User Profile
      if params[:user_id]
        @membership.user_id = params[:user_id]
        @preselected_user = User.find_by(id: params[:user_id])
      end
    end

    def create
      @membership = Membership.new(membership_params)

      if @membership.save
        # Format amount for the flash message
        amount = view_context.number_to_currency(@membership.amount_paid)
        msg = t('admin.memberships.flash.created', amount: amount)
        
        # Redirect back to User Profile for better flow
        redirect_to admin_user_path(@membership.user_id), notice: msg
      else
        @preselected_user = User.find_by(id: membership_params[:user_id]) if membership_params[:user_id]
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @membership.update(membership_params)
        redirect_to admin_memberships_path, notice: t('admin.memberships.flash.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @membership.destroy
      redirect_to admin_memberships_path, notice: t('admin.memberships.flash.deleted')
    end

    private

    def set_membership
      @membership = Membership.find(params[:id])
    end

    def set_collections
      @plans = MembershipPlan.active.order(:price)
      @packages = MembershipPackage.active.order(:name)
      @users = User.order(:first_name) 
    end

    def membership_params
      params.require(:membership).permit(:user_id, :membership_plan_id, :membership_package_id, :start_date, :end_date, :amount_paid, :status)
    end
  end
end