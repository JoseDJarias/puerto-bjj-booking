class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  #allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # === AUTHORIZATION HELPERS ===
  
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

  def require_active_membership
    unless Current.user&.can_book_classes?
      redirect_to root_path, alert: t('flash.alerts.active_membership_required')
    end
  end
end
