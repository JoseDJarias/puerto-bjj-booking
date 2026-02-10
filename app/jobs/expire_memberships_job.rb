class ExpireMembershipsJob < ApplicationJob
  queue_as :default

  def perform
    expired_count = Membership.where(status: :active)
                              .where("end_date < ?", Date.current)
                              .update_all(status: :expired)
    
    if expired_count > 0
      Rails.logger.info "Nightly cleanup: #{expired_count} memberships expired."
    end
  end
end