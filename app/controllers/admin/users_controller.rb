module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy approve]

    def index
      @users = User.order(approved_at: :asc, created_at: :desc)
    end

    def show
      @memberships = @user.memberships.includes(:membership_plan, :membership_package).order(end_date: :desc)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: t('admin.users.flash.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: t('admin.users.flash.deleted')
    end

    def approve
      @user.update(approved_at: Time.current, status: :active)
      redirect_to admin_users_path, notice: t('admin.users.flash.approved')
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_address, :phone, :role, :status)
    end
  end
end