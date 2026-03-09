class ClassSchedulesController < ApplicationController
  before_action :require_booking_access

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @class_schedules = ClassSchedule.for_date(@date)
                                    .visible_for(Current.user)
                                    .active
                                    .includes(:class_type, :instructor, :bookings)
  end

  def show
    @schedule = ClassSchedule.find(params[:id])
    @booking = current_user.bookings.find_by(class_schedule: @schedule)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def week
    @user = Current.user # Importante para las reglas de acceso
    @week_start = week_param.presence&.to_date || Date.current.beginning_of_week(:monday)
    @week_start = @week_start.beginning_of_week(:monday)
    @week_end = @week_start + 6.days
    @days = (@week_start..@week_end).to_a
  
    @schedules_by_date = ClassSchedule.active
                                      .for_range(@week_start, @week_end)
                                      .includes(:class_type, :instructor, :bookings)
                                      .order(:starts_at)
                                      .group_by(&:date)
  end

  def participants
    @schedule = ClassSchedule.find(params[:id])
    
    respond_to do |format|
      format.html do
        if turbo_frame_request?
          render partial: "class_schedules/partials/participants_list", 
                 locals: { schedule: @schedule },
                 layout: false
        else
          render partial: "class_schedules/partials/participants_list", locals: { schedule: @schedule }
        end
      end
    end
  end

  private

  def week_param
    params[:week]
  end

end