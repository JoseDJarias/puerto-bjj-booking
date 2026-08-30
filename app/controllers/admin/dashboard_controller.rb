# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < OperationsController
    def index
      @base_date = ClassSchedule.logical_today 
  
      @offset = params[:offset].to_i
      
      @date = @base_date + @offset.days
      
      # Get the classes for that specific operative date
      scope = current_user.admin? ? ClassSchedule : ClassSchedule.where(instructor: current_user)
      @schedules = scope.for_date(@date)
                        .includes(:class_type, :instructor)
                        .order(:starts_at)
    
      if current_user.admin?
        @pending_approvals = User.where(approved_at: nil).count
      end
    end
  end
end