module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy approve]

    def index
      scope = User.includes(memberships: :membership_package).order(created_at: :desc)

      case params[:filter]
      when "pending"
        scope = scope.pending
      when "approved"
        scope = scope.approved
      when "inactive"
        scope = scope.where(status: :inactive)
      end

      #Package Filtering
      if params[:package_id].present?
        scope = scope.joins(:memberships)
                    .where(memberships: { 
                      membership_package_id: params[:package_id],
                      status: :active
                    }).distinct
      end

      if params[:query].present?
        scope = scope.search_by_query(params[:query])
      end

      @pagy, @users = pagy(:countless, scope, limit: 15)

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

      @user.admin_editing_password = true

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
      if @user.update(approved_at: Time.current, status: :active)
        flash.now[:notice] = "Usuario #{@user.full_legal_name} aprobado correctamente."
      else
        flash.now[:alert] = "No se pudo aprobar: #{@user.errors.full_messages.to_sentence}"
      end
      respond_to do |format|
        format.html { redirect_to admin_users_path, notice: flash[:notice] || flash[:alert] }
        format.turbo_stream
      end
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