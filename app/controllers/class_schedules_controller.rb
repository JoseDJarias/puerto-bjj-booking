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
    
    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "class_schedules/participants_list", 
                 locals: { schedule: @schedule },
                 layout: false
        else
          render partial: "class_schedules/participants_list", locals: { schedule: @schedule }
        end
      end
    end
  end

  private

  def week_param
    params[:week]
  end

end