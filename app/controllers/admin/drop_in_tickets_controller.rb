module Admin
  class DropInTicketsController < BaseController
    before_action :set_user
    before_action :set_ticket, only: %i[void reset_usage destroy]

    # Sell tickets
    def create
      quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
      
      tickets_data = quantity.times.map do
        { 
          user_id: @user.id, 
          price_paid: 5000, 
          status: 0, # unused
          created_at: Time.current, 
          updated_at: Time.current 
        }
      end

      DropInTicket.insert_all(tickets_data) if tickets_data.any?
      respond_after_action("Se agregaron #{quantity} créditos correctamente.")
    end

    # Remove access
    def void
      @ticket.void!
      respond_after_action("Ticket ##{@ticket.id} anulado.")
    end

    # Reset to available
    def reset_usage
      @ticket.reset!
      respond_after_action("Ticket ##{@ticket.id} vuelve a estar disponible.")
    end

    # Physical deletion (Only if necessary to clean the DB), please use the void method instead.
    def destroy
      @ticket.destroy
      respond_after_action("Ticket eliminado del historial.")
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_ticket
      @ticket = @user.drop_in_tickets.find(params[:id])
    end

    def respond_after_action(notice_message)
      flash.now[:notice] = notice_message
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("drop_in_management_#{@user.id}",
                                 partial: "admin/users/drop_in_management",
                                 locals: { user: @user }),
            turbo_stream.update("flash", partial: "layouts/flash")
          ]
        end
        format.html { redirect_to admin_user_path(@user), notice: notice_message }
      end
    end
  end
end