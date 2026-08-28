class ClassSchedulesController < ApplicationController
  before_action :require_booking_access


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