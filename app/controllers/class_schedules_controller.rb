class ClassSchedulesController < ApplicationController
  before_action :require_booking_access

  def index
    @class_schedules = ClassSchedule.for_booking_today
                                    .where(class_type: Current.user.bookable_class_types)
                                    .includes(:class_type, :instructor)
  end

  def week
    @week_start = week_param.presence&.to_date || Date.current.beginning_of_week(:monday)
    @week_start = @week_start.beginning_of_week(:monday)
    @week_end = @week_start + 6.days
    @days = (@week_start..@week_end).to_a

    schedules = ClassSchedule.active
                             .for_range(@week_start, @week_end)
                             .includes(:class_type, :instructor)
                             .order(:starts_at)
    @schedules_by_date = schedules.group_by(&:date)
  end

  private

  def week_param
    params[:week]
  end

end