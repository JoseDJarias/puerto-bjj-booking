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

      @back_path = if params[:from] == 'dashboard'
                     admin_dashboard_path
                   else
                     admin_class_schedules_path
                   end

      @back_label = params[:from] == 'dashboard' ? "Dashboard" : t('admin.class_schedules.index.title')
                        
      respond_to do |format|
        format.html { 
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
            format.turbo_stream { render "admin/bookings/update" }
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

    def batch_new
      @class_schedule = ClassSchedule.new
      @default_start = Date.current
      @default_end = 3.months.from_now.to_date
    end

    def process_batch
      safe_params = class_schedule_params
      
      day_configs = safe_params[:day_configs]&.to_h&.values&.select { |c| c[:active] == "1" } || []

      if day_configs.empty?
        return redirect_to batch_new_admin_class_schedules_path, 
                          alert: "Debes seleccionar al menos un día en el grid."
      end

      start_date = Date.parse(safe_params[:start_date])
      end_date = Date.parse(safe_params[:end_date])
      date_range = start_date..end_date

      base_attributes = safe_params.except(:start_date, :end_date, :day_configs)

      total_processed = 0
    
      # Iterate over the array of times to delete each one specifically
      if params[:bulk_action] == "destroy"
        day_configs.each do |config|
          config[:times].each do |time_string|
            next if time_string.blank?
            total_processed += ClassSchedule.where(starts_at: date_range)
                                           .where(class_type_id: base_attributes[:class_type_id])
                                           .matching_schedule([config[:day_index]], time_string)
                                           .destroy_all.count
          end
        end
        flash_message = "Se eliminaron #{total_processed} clases correctamente."
      else
        day_configs.each do |config|
          config[:times].each do |time_string|
            next if time_string.blank?
            
            total_processed += ClassSchedule.bulk_schedule(
              { days: [config[:day_index].to_i], time: time_string }, 
              date_range, 
              base_attributes
            )
          end
        end
        flash_message = t('admin.class_schedules.flash.created_batch', count: total_processed)
      end
    
      redirect_to admin_class_schedules_path, notice: flash_message
    end

    private

    def set_class_schedule
      @class_schedule = ClassSchedule.find(params[:id])
    end

    def set_collections
      @class_types = ClassType.active.order(:name)
      @instructors = User.eligible_instructors
    end

    def class_schedule_params
      params.require(:class_schedule).permit(
        :class_type_id, 
        :instructor_id, 
        :starts_at,
        :duration_minutes, 
        :capacity, 
        :modality,
        :cancelled,
        :start_date,
        :end_date,
        day_configs: [
          :active, 
          :day_index, 
          times: []
        ]
      )
    end
  end
end