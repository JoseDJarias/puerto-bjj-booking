module Admin
  class ClassSchedulesController < OperationsController
    before_action :require_admin, only: %i[new create edit update destroy batch_new process_batch]
    before_action :set_class_schedule, only: %i[show edit update destroy attendance]
    before_action :set_collections, only: %i[new edit batch_new]

    def index
      start_date = params.fetch(:start_date, Date.current).to_date
      
      # monthly calendar
      @class_schedules = ClassSchedule.for_range(start_date.beginning_of_month, start_date.end_of_month)
                                      .includes(:class_type, :instructor)
    end

    def show
      @class_schedule = ClassSchedule.includes(
        :class_type,
        :instructor,
        bookings: { user: [:memberships, :drop_in_tickets] }
        ).find(params[:id])
      @bookings = @class_schedule.bookings.order(status: :asc, updated_at: :desc)
      
      # modal: manual search
      booked_user_ids = @class_schedule.active_bookings_list.map(&:user_id)
      @users_available = User.includes(:memberships, :drop_in_tickets)
                        .where.not(id: booked_user_ids)
                        .order(:first_name)
                        
      respond_to do |format|
        format.html { 
          # If it's a Turbo Frame request, remove the layout
          layout = turbo_frame_request? ? false : "admin"
          render layout: layout 
        }
      end
    end

    def new
      @class_schedule = ClassSchedule.new(starts_at: Time.current.change(min: 0))
    end

    def create
      @class_schedule = ClassSchedule.new(class_schedule_params)
      if @class_schedule.save
        redirect_to admin_class_schedules_path, notice: t('admin.class_schedules.flash.created')
      else
        set_collections
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # 1. If the 'action_type' parameter is present, it's a quick attendance action
      if params[:action_type].present?
        # Here you need to find the BOOKING, not the class. 
        # Make sure to send the booking_id in your attendance buttons.
        @booking = Booking.find(params[:booking_id]) 
        
        target_status = case params[:action_type]
                        when "check_in"
                          @booking.attended? ? "confirmed" : "attended"
                        when "toggle_block"
                          @booking.blocked? ? "confirmed" : "blocked"
                        else
                          @booking.status
                        end
    
        if @booking.update_status!(target_status, current_user)
          respond_to do |format|
            format.turbo_stream { render "admin/bookings/update" } # O donde tengas tu stream
            format.html { redirect_back fallback_location: admin_dashboard_path }
          end
        end
    
      # 2. If there is no action_type, it's the normal form edit of the class
      else
        if @class_schedule.update(class_schedule_params)
          redirect_to admin_class_schedule_path(@class_schedule), notice: "Clase actualizada correctamente."
        else
          render :edit, status: :unprocessable_entity
        end
      end
    end
    # app/controllers/admin/class_schedules_controller.rb
    def attendance
      @schedule = ClassSchedule.find(params[:id])
      
      active_statuses = [0, 3] 
    
      enrolled_user_ids = @schedule.bookings
                                   .where(status: active_statuses)
                                   .pluck(:user_id)
                                   .compact
                                   .uniq
    
      # Roster list
      @bookings = @schedule.bookings
                           .includes(user: [:memberships, :drop_in_tickets])
                           .where(status: active_statuses)
                           .order("users.first_name ASC")
    
      # Available users (Excluding the ones that have a place and the admin)
      @available_users = User.active
                             .includes(:memberships, :drop_in_tickets)
                             .where.not(id: enrolled_user_ids + [1])
                             .order(:first_name)
    end

    def destroy
      @class_schedule.destroy
      redirect_to admin_class_schedules_path, notice: t('admin.class_schedules.flash.deleted')
    end

    # --- BULK GENERATOR ---
    def batch_new
      @class_schedule = ClassSchedule.new
      @default_start = Date.current
      @default_end = 3.months.from_now.to_date
    end

    def process_batch
      #Create and batch destroy of classes
      schedule_data = params[:schedule]
      days = schedule_data[:days].select(&:present?).map(&:to_i)
      discipline_id = params[:class_schedule][:class_type_id]
      instructor_id = params[:class_schedule][:instructor_id]
      
      if schedule_data[:time].blank? || schedule_data[:days].blank?
        return redirect_to batch_new_admin_class_schedules_path, alert: "Por favor selecciona hora y días."
      end

      start_date = Date.parse(schedule_data[:start_date])
      end_date = Date.parse(schedule_data[:end_date])
      date_range = start_date..end_date

      if params[:bulk_action] == "destroy"
        target_classes = ClassSchedule.where(
          starts_at: start_date.beginning_of_day..end_date.end_of_day,
          class_type_id: params[:class_schedule][:class_type_id],
          instructor_id: params[:class_schedule][:instructor_id]
        ).matching_schedule(days, schedule_data[:time])

        count = target_classes.destroy_all.count
        flash_message = "Se eliminaron #{count} clases correctamente."
      else
        base_attributes = {
          class_type_id: class_schedule_params[:class_type_id],
          instructor_id: class_schedule_params[:instructor_id],
          duration_minutes: class_schedule_params[:duration_minutes],
          capacity: class_schedule_params[:capacity]
        }

        count = ClassSchedule.bulk_schedule(
          { days: days, time: schedule_data[:time] }, 
          date_range, 
          base_attributes
        )
        flash_message = t('admin.class_schedules.flash.created_batch', count: count)
      end
      redirect_to admin_class_schedules_path, notice: flash_message
    rescue StandardError => e
      redirect_to batch_new_admin_class_schedules_path, alert: t('admin.class_schedules.flash.error_batch', message: e.message)
    end

    private

    def set_class_schedule
      @class_schedule = ClassSchedule.find(params[:id])
    end

    def set_collections
      @class_types = ClassType.active.order(:name)
      @instructors = User.where(role: [:instructor, :admin]).order(:first_name)
    end

    def class_schedule_params
      params.require(:class_schedule).permit(:class_type_id, :instructor_id, :starts_at, :duration_minutes, :capacity, :cancelled, :modality)
    end
  end
end