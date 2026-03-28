class PasswordsController < ApplicationController
  layout "auth"
  
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t('flash.alerts.try_again_later') }

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    if user
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t('flash.notices.password_reset_sent')
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: t('flash.notices.password_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
