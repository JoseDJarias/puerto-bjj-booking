class BookingsController < ApplicationController

  def create
    @schedule = ClassSchedule.find(params[:class_schedule_id])
    @booking = Booking.find_or_initialize_by(user: current_user, class_schedule: @schedule)

    begin
      @schedule.with_lock do
        if @booking.new_record?
          @booking.update_status!(:confirmed, current_user)
        else
          @booking.toggle_by_user!
        end
      end
      
      msg = @booking.active_status? ? "¡Clase reservada!" : "Reserva cancelada."
      
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("action_button_schedule_#{@schedule.id}", 
                                 partial: "class_schedules/action_button", 
                                 locals: { schedule: @schedule, user: current_user }),
            
            turbo_stream.replace("spots_schedule_#{@schedule.id}", 
                                 partial: "class_schedules/spots", 
                                 locals: { schedule: @schedule }),

            turbo_stream.update("flash", partial: "layouts/flash")
          ]
        end
        format.html { redirect_back fallback_location: root_path, notice: msg }
      end

    rescue StandardError => e
      Rails.logger.error "ERROR EN CONTROLLER: #{e.message}"
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = e.message
          render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
        end
        format.html { redirect_back fallback_location: root_path, alert: e.message }
      end
    end
  end
end