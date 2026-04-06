class ClassSchedulesController < ApplicationController
  before_action :require_booking_access
  def index
    # 1. Date calculation (defaults to logical today)
    @date = params[:date] ? Date.parse(params[:date]) : ClassSchedule.logical_today
    @week_start = @date.beginning_of_week(:monday)
    @week_end = @week_start + 6.days
    @days_range = (@week_start..@week_end).to_a

    # 2. View Mode (day is default for quick booking)
    @view_mode = params[:view_mode] || "day"

    # 3. Data Fetching
    # We fetch the full week to allow switching days without new DB queries if needed,
    # but here we keep it simple and reactive.
    @schedules_by_date = ClassSchedule.for_range(@week_start, @week_end)
                                      .visible_for(Current.user)
                                      .includes(:class_type, :instructor, :bookings)
                                      .order(:starts_at)
                                      .group_by(&:date)

    @class_schedules = @schedules_by_date[@date] || []

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @schedule = ClassSchedule.find(params[:id])
    @booking = current_user.bookings.find_by(class_schedule: @schedule)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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