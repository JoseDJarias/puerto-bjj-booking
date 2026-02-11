class ClassSchedulesController < ApplicationController

  def index
    @class_schedules = ClassSchedule.upcoming
                                    .includes(:class_type, :instructor)
                                    .limit(20)
  end
end