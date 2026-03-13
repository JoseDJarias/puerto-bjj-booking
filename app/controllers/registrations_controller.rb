class RegistrationsController < ApplicationController
  layout "auth"
  
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: t('flash.alerts.try_again_later') }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: t('flash.notices.welcome')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :identification, :email_address, :password, :password_confirmation)
    end
end
