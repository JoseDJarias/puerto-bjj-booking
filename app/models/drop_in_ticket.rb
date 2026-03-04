class DropInTicket < ApplicationRecord
  belongs_to :user
  belongs_to :booking, optional: true

  enum :status, { unused: 0, used: 1, voided: 2 }, default: :unused

  scope :unused, -> { where(status: :unused) }
  scope :used_today, -> { used.where(used_at: Time.current.all_day) }

 def activate!(first_booking)
  update!(
    status: :used,
    booking: first_booking,
    used_at: Time.current
  )
  end

  def reset!
    update!(status: :unused, used_at: nil, booking: nil)
  end

  def void!
    update!(status: :voided)
  end

  def covers_date?(date)
    used? && used_at.to_date == date.to_date
  end
end