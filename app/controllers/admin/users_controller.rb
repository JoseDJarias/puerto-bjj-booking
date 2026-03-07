module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy approve]

    def index
      @users = User.order(approved_at: :asc, created_at: :desc)
    end

    def show
      @memberships = @user.memberships.includes(:membership_plan, :membership_package).order(end_date: :desc)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_user_path(@user), notice: "Usuario creado exitosamente."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      filtered_params = user_params
      if filtered_params[:password].blank?
        filtered_params.delete(:password)
        filtered_params.delete(:password_confirmation)
      end

      if @user.update(filtered_params)
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
      params.require(:user).permit(:first_name, :last_name, :email_address, :phone_number, :role, :status, :identification, :nickname, :password, :password_confirmation)
    end
  end
end