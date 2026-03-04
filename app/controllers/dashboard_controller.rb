# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @user = Current.user

    if @user.approved? && !@user.has_booking_access?
      @packages = MembershipPackage.active.includes(:class_types)
      @plans = MembershipPlan.active.order(duration_months: :asc)
    end
  end
end
