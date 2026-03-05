class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  #allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :user_signed_in?

  private

  # === AUTHORIZATION HELPERS ===

  def current_user
    Current.session&.user
  end

  def user_signed_in?
    current_user.present?
  end
  
  def require_admin
    unless Current.user&.admin?
      redirect_to root_path, alert: t('flash.alerts.admin_required')
    end
  end

  def require_instructor_or_admin
    unless Current.user&.can_check_in_students?
      redirect_to root_path, alert: t('flash.alerts.access_denied')
    end
  end

  def require_booking_access
    return if Current.user&.admin?
    return if Current.user&.has_booking_access?
    redirect_to root_path, alert: t('flash.alerts.booking_access_required')
  end

  def require_active_membership
    require_booking_access
  end
end
