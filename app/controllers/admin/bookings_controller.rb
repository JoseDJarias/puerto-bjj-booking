module Admin
  class BookingsController < BaseController
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

    def destroy
      @booking = Booking.find(params[:id])
      # State: Cancelled by Admin
      @booking.update_status!(:cancelled_admin, current_user)
      redirect_back fallback_location: admin_root_path, notice: "Reserva cancelada."
    end

    def check_in
      @booking = Booking.find(params[:id])
      @booking.update_status!(:attended, current_user)
      
      # Response Turbo to be instant without reloading
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: admin_root_path }
      end
    end
  end
end