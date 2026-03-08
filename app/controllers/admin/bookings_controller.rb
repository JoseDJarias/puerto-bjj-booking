module Admin
  class BookingsController < BaseController
    before_action :set_booking, only: [:check_in, :destroy]

    def create
      @schedule = ClassSchedule.find(params[:booking][:class_schedule_id])
      user = User.find(params[:booking][:user_id])

      # We search or initialize
      @booking = Booking.find_or_initialize_by(user: user, class_schedule: @schedule)
      
      # MAGIC: Since we are Admin, we use update_status! passing 'current_user' (which is admin)
      # The model will detect that it is admin and skip the capacity/limit validations.
      if @booking.update_status!(:confirmed, current_user)
        redirect_to admin_class_schedule_path(@schedule), notice: "#{user.first_name} agregado a la clase."
      else
        redirect_to admin_class_schedule_path(@schedule), alert: "No se pudo agregar."
      end
    end

    def check_in
      @booking = Booking.find(params[:id])
      target_status = (params[:attended] == "false") ? :confirmed : :attended
      
      if @booking.update_status!(target_status, current_user)
        respond_to do |format|
          format.turbo_stream { render turbo_stream: [] } 
          format.html { redirect_back fallback_location: root_path }
        end
      else
        head :unprocessable_entity
      end
    end

    def destroy
      @schedule = @booking.class_schedule
      # En lugar de borrar el registro (destroy físico), cambiamos el estado
      # Esto permite que el broadcast del modelo actualice la UI
      @booking.update_status!(:cancelled_admin, current_user)
      
      respond_to do |format|
        format.turbo_stream { render_flash("Reserva removida") }
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