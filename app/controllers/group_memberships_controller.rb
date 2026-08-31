class GroupMembershipsController < ApplicationController
  before_action :set_group
  before_action :set_membership

  def accept
    if @membership.update(status: :accepted)
      redirect_to group_path(@group), notice: t("group_memberships.flash.accepted", name: @group.name, default: "¡Has aceptado la invitación!")
    else
      redirect_to groups_path, alert: "No se pudo aceptar la invitación."
    end
  end

  def decline
    if @membership.update(status: :declined)
      redirect_to groups_path, notice: t("group_memberships.flash.declined", default: "Invitación rechazada.")
    else
      redirect_to groups_path, alert: "No se pudo rechazar la invitación."
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_membership
    @membership = current_user.group_memberships.find_by!(group: @group)
  end
end
