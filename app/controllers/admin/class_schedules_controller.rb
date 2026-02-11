module Admin
  class ClassSchedulesController < BaseController
    before_action :set_class_schedule, only: %i[show edit update destroy]
    before_action :set_collections, only: %i[new edit batch_new]

    def index
      start_date = params.fetch(:start_date, Date.current).to_date
      @class_schedules = ClassSchedule.for_range(start_date.beginning_of_month, start_date.end_of_month)
                                      .includes(:class_type, :instructor)
    end

    def show
      @bookings = @class_schedule.bookings
                                 .includes(:user)
                                 .order(status: :asc, updated_at: :desc)
      
      booked_user_ids = @class_schedule.bookings.active.pluck(:user_id)
      @users_available = User.where.not(id: booked_user_ids).order(:first_name)
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
      if @class_schedule.update(class_schedule_params)
        redirect_to admin_class_schedules_path, notice: t('admin.class_schedules.flash.updated')
      else
        set_collections
        render :edit, status: :unprocessable_entity
      end
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

    def batch_create
      schedule_data = params[:schedule]
      days = schedule_data[:days].select(&:present?).map(&:to_i)
      
      start_date = Date.parse(schedule_data[:start_date])
      end_date = Date.parse(schedule_data[:end_date])
      date_range = start_date..end_date

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

      redirect_to admin_class_schedules_path, notice: t('admin.class_schedules.flash.created_batch', count: count)
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
      params.require(:class_schedule).permit(:class_type_id, :instructor_id, :starts_at, :duration_minutes, :capacity, :cancelled)
    end
  end
end