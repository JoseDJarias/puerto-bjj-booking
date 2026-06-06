class ExpireMembershipsJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current
    expired_count = Membership.where(status: :active)
                              .where("end_date < ?", Time.zone.today)
                              .update_all(status: :expired, updated_at: now)

    if expired_count > 0
      Rails.logger.info "[ExpireMembershipsJob] #{now}: Se expiraron #{expired_count} membresías."
    else
      Rails.logger.info "[ExpireMembershipsJob] #{now}: No se encontraron membresías para expirar."
    end
  rescue StandardError => e
    Rails.logger.error "[ExpireMembershipsJob] ERROR: #{e.message}"
    raise e
  end
end