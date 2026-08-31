class GroupsController < ApplicationController
  before_action :set_group, only: [:show]

  def index
    # We include group_memberships to filter out pending invitations if needed.
    # Group memberships that belong to the user
    @memberships = current_user.group_memberships.includes(:group)
    
    @accepted_groups = @memberships.select(&:accepted?).map(&:group)
    @invited_memberships = @memberships.select(&:invited?)
  end

  def show
    unless @group.users.include?(current_user)
      redirect_to groups_path, alert: "No tienes permiso para ver este grupo."
      return
    end

    membership = current_user.group_memberships.find_by(group: @group)
    if membership&.invited?
      redirect_to groups_path, alert: "Debes aceptar la invitación primero."
      return
    end

    # Users can't upload attachments, but can see them.
    @messages = @group.messages.includes(:user, attachments_attachments: :blob).order(created_at: :asc)
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end
end
