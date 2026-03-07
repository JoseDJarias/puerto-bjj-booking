class ClassSchedulesController < ApplicationController
  before_action :require_booking_access

  def index
    @class_schedules = ClassSchedule.for_booking_today
                                    .visible_for(Current.user)
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

  def participants
    @schedule = ClassSchedule.find(params[:id])
    @active_bookings = @schedule.active_bookings.includes(:user)
    
    render layout: false
  end

  private

  def week_param
    params[:week]
  end

end