module Admin
  class MembershipsController < BaseController
    before_action :set_membership, only: %i[edit update destroy]
    before_action :set_collections, only: %i[new create edit update]

    def index
      scope = Membership.includes(:user, :membership_plan, :membership_package)
                        .order(created_at: :desc)

      case params[:filter]
      when "active"
        scope = scope.current
      when "expired"
        scope = scope.expired_listing
      end

      if params[:query].present?
        sanitized_query = ActiveRecord::Base.sanitize_sql_like(params[:query])
        q = "%#{sanitized_query}%"
        scope = scope.joins(:user).where(
          "users.first_name LIKE :q OR users.last_name LIKE :q OR users.email_address LIKE :q OR users.phone_number LIKE :q",
          q: q
        )
      end

      @pagy, @memberships = pagy(:countless, scope, limit: 10)

      respond_to do |format|
        format.html
        format.turbo_stream
      end
    end
      
    def new
      @membership = Membership.new(membership_params)
      @membership.start_date ||= Date.current 
      
      set_collections
    end

    def create
      @membership = Membership.new(membership_params)
      @membership.start_date ||= Date.current

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

    def calculate_totals
      clean_params = membership_params.except(:amount_paid)
      @membership = Membership.new(clean_params)
      @membership.preview_totals if @membership.membership_package_id.present? && @membership.membership_plan_id.present?

      render json: {
        amount: @membership.amount_paid.to_i,
        end_date: @membership.end_date ? l(@membership.end_date, format: :long) : t("admin.memberships.form.select_plan_package")
      }
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
      params.fetch(:membership, {}).permit(:user_id, :membership_plan_id, :membership_package_id, :start_date, :end_date, :amount_paid, :status)
    end
  end
end