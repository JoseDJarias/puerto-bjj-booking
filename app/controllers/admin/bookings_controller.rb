module Admin
  class BookingsController < OperationsController
    before_action :set_booking, only: [:update, :destroy, :toggle_attendance]

    def create    
      @schedule = ClassSchedule.find(params[:booking][:class_schedule_id])
      user = User.find(params[:booking][:user_id])
    
      @booking = Booking.find_or_initialize_by(user: user, class_schedule: @schedule)
      
      if @booking.update_status!(:confirmed, current_user)
        # Reload @schedule.bookings for active_bookings_count and other methods.
        @schedule.bookings.reload 
    
        flash.now[:notice] = "#{user.first_name} agregado."

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.prepend("flash", partial: "layouts/flash"),
              turbo_stream.remove("empty_tatami_msg")
            ]
          end
          format.html { redirect_to attendance_admin_class_schedule_path(@schedule), notice: "#{user.first_name} agregado." }
        end
      else
        redirect_to attendance_admin_class_schedule_path(@schedule), alert: "No se pudo agregar."
      end
    end

    def update
      target_status = params[:action_type] == "toggle_block" ? 
                      (@booking.blocked? ? "confirmed" : "blocked") : 
                      @booking.status

      if @booking.update_status!(target_status, current_user)
        respond_to do |format|
          format.turbo_stream { render :update_mastermind }
          format.html { redirect_back fallback_location: admin_dashboard_path }
        end
      end
    end

    def toggle_attendance
      new_status = @booking.attended? ? :confirmed : :attended
      
      if @booking.update_status!(new_status, current_user)
        @class_schedule = @booking.class_schedule
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace(helpers.dom_id(@booking), 
                partial: "admin/class_schedules/partials/booking_row", 
                locals: { booking: @booking }),
            ]
          end
          format.html { redirect_to admin_class_schedule_path(@booking.class_schedule) }
        end
      end
    end

    def destroy
      @schedule = @booking.class_schedule
      # Instead of deleting the record (destroy physically), we change the status
      # This allows the model broadcast to update the UI
      @booking.update_status!(:cancelled_admin, current_user)
      @schedule.bookings.reload
      respond_to do |format|
        format.turbo_stream { render "admin/bookings/destroy" }
        format.html { redirect_back fallback_location: admin_root_path }
      end
    end
    
    private
    
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def render_flash(msg)
      flash.now[:notice] = msg
      render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
    end

  end
end