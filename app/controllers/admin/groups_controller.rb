module Admin
  class GroupsController < BaseController
    before_action :set_group, only: %i[show edit update destroy]
    
    protected
    
    def require_admin
      redirect_to root_path, alert: "Acceso denegado." unless current_user.admin? || current_user.instructor?
    end

    public

    def index
      if current_user.admin?
        @groups = Group.all.order(created_at: :desc)
      else
        @groups = current_user.created_groups.order(created_at: :desc)
      end
      @member_counts = GroupMembership.where(group: @groups).group(:group_id).count
    end

    def show
      @messages = @group.messages.includes(:user, attachments_attachments: :blob).order(created_at: :asc)
      @users = User.approved.active_status.order(:first_name) - @group.users
    end

    def new
      @group = Group.new
    end

    def create
      @group = current_user.created_groups.build(group_params)
      if @group.save
        redirect_to admin_groups_path, notice: t("admin.groups.flash.created", default: "Grupo creado")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @group.update(group_params)
        redirect_to admin_groups_path, notice: t("admin.groups.flash.updated", default: "Grupo actualizado")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @group.destroy
      redirect_to admin_groups_path, notice: t("admin.groups.flash.destroyed", default: "Grupo eliminado")
    end

    private

    def set_group
      @group = Group.find(params[:id])
      unless current_user.admin? || @group.creator_id == current_user.id
        redirect_to admin_groups_path, alert: "No tienes permiso para ver este grupo."
      end
    end

    def group_params
      params.require(:group).permit(:name, :description)
    end
  end
end
