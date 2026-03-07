class BookingsController < ApplicationController
  def create
    @schedule = ClassSchedule.find(params[:class_schedule_id])
    
    unless current_user.authorized_for?(@schedule.class_type)
      return redirect_back(fallback_location: root_path, 
                           alert: t('bookings.messages.membership_required'))
    end

    @booking = Booking.find_or_initialize_by(user: current_user, class_schedule: @schedule)

    if @booking.handle_user_action!(current_user)
      msg = @booking.active_status? ? t('bookings.actions.success') : t('bookings.actions.released')
      flash.now[:notice] = msg
      
    else
      flash.now[:alert] = @booking.errors.full_messages.to_sentence
      render status: :unprocessable_entity
    end
  end
end