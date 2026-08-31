class MessagesController < ApplicationController
  before_action :set_group

  def create
    @message = @group.messages.build(message_params)
    @message.user = current_user
    
    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to group_path(@group) }
      end
    else
      redirect_to group_path(@group), alert: "Error al enviar mensaje."
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
    unless @group.users.include?(current_user)
      redirect_to groups_path, alert: "No tienes permiso para enviar mensajes en este grupo."
    end
  end

  def message_params
    # Users can only send text content, no attachments allowed.
    params.require(:message).permit(:content)
  end
end
