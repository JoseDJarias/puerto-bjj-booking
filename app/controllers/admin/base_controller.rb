class Admin::BaseController < ApplicationController
  layout "admin"
  #All admin routes are protected and require admin privileges
  before_action :require_admin
end
