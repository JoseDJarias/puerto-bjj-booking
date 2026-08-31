module Admin
  class GroupMembershipsController < BaseController
    before_action :set_group

    def create
      @membership = @group.group_memberships.build(user_id: params[:user_id], status: :invited)
      
      if @membership.save
        redirect_to admin_group_path(@group), notice: t("group_memberships.flash.invited", name: @membership.user.display_name, default: "Invitación enviada.")
      else
        redirect_to admin_group_path(@group), alert: "No se pudo invitar al usuario."
      end
    end

    def destroy
      @membership = @group.group_memberships.find(params[:id])
      @membership.destroy
      redirect_to admin_group_path(@group), notice: t("group_memberships.flash.removed", default: "Usuario removido.")
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
      unless current_user.admin? || @group.creator_id == current_user.id
        redirect_to admin_groups_path, alert: "No tienes permiso para gestionar este grupo."
      end
    end
  end
end
