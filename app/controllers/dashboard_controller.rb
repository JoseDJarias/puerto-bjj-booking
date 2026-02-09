# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @user = Current.user
  end
end
