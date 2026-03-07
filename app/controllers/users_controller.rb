class UsersController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    params_to_update = user_params
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user.update(params_to_update)
      redirect_to root_path, notice: "Tu perfil ha sido actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user 
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :identification, 
      :nickname, :phone_number, :email_address,
      :password, :password_confirmation
    )
  end
end
