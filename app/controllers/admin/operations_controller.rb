# app/controllers/admin/operations_controller.rb
module Admin
  class OperationsController < ApplicationController
    layout "admin"
    # Only those who can pass list (Admin + Instructor)
    before_action :require_instructor_or_admin 
  end
end