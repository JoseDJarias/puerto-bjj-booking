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

  def update
    @schedule = ClassSchedule.find(params[:id])
    if current_user&.admin? || current_user&.instructor?
      if @schedule.update(params.require(:class_schedule).permit(:topic, :notes))
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("notes_schedule_#{@schedule.id}", partial: "class_schedules/partials/notes_section", locals: { schedule: @schedule }),
              turbo_stream.replace("universal_card_#{@schedule.id}", partial: "class_schedules/partials/class_card_universal", locals: { schedule: @schedule, context: :dashboard, user: current_user })
            ]
          end
          format.html { redirect_to class_schedule_path(@schedule), notice: "Notas actualizadas." }
        end
      else
        redirect_to class_schedule_path(@schedule), alert: "Error actualizando."
      end
    else
      redirect_to root_path, alert: "No autorizado."
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