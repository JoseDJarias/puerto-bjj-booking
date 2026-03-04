class ClassSchedulesController < ApplicationController
  before_action :require_booking_access

  def index
    @class_schedules = ClassSchedule.for_booking_today
                                    .where(class_type: Current.user.bookable_class_types)
                                    .includes(:class_type, :instructor)
  end
end