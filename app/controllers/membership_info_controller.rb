class MembershipInfoController < ApplicationController
  def show
    @current_memberships = Current.user
                                  .memberships
                                  .current
                                  .includes(:membership_plan, :membership_package)
                                  .order(end_date: :asc)
    @unused_drop_in_count = Current.user.unused_tickets_count
    @drop_in_active_today = Current.user.drop_in_active_today?
  end

  def history
    user = Current.user
    @past_memberships = user.memberships.past.includes(:membership_plan, :membership_package).order(end_date: :desc)
    # TODO: Call a public method at model level, that calls a private method thst query that data
    @drop_in_history = user.drop_in_tickets.where(status: [:used, :voided]).order(Arel.sql("used_at DESC NULLS LAST, updated_at DESC"))
  end
end
