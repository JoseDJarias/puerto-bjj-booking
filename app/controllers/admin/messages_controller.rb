module Admin
  class MessagesController < BaseController
    before_action :set_group

    def create
      @message = @group.messages.build(message_params)
      @message.user = current_user
      
      if @message.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_group_path(@group) }
        end
      else
        redirect_to admin_group_path(@group), alert: "Error al enviar mensaje."
      end
    end

    private

    def set_group
      @group = Group.find(params[:group_id])
    end

    def message_params
      params.require(:message).permit(:content, attachments: [])
    end
  end
end
