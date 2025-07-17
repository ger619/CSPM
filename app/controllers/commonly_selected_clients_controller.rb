class CommonlySelectedClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commonly_selected_client, only: [:destroy]

  def index
    @common_clients = current_user.common_clients.order(:name)
    @available_clients = Client.where.not(id: @common_clients.pluck(:id))
  end

  def create
    @common_client = current_user.commonly_selected_clients.new(client_id: params[:client_id])

    if @common_client.save
      redirect_back fallback_location: cease_fire_report_path, notice: "Client added to your common list."
    else
      redirect_back fallback_location: cease_fire_report_path, alert: @common_client.errors.full_messages.to_sentence
    end
  end

  def destroy
    @common_client = current_user.commonly_selected_clients.find_by!(client_id: params[:id])
    @common_client.destroy
    
    respond_to do |format|
        format.html do
        redirect_back fallback_location: cease_fire_report_path, 
                    notice: "Client removed from your common list."
        end
        format.turbo_stream do
        render turbo_stream: [
            turbo_stream.remove(@common_client),
            turbo_stream.append("flash", partial: "shared/flash", 
                                locals: { notice: "Client removed from your common list." })
        ]
        end
    end
  end

    def remove_client
        @common_client = current_user.commonly_selected_clients.find_by!(client_id: params[:client_id])
        @common_client.destroy

        respond_to do |format|
            format.html do
            redirect_back fallback_location: cease_fire_report_path,
                        notice: "Client removed from your common list."
            end
        end
    end


  private

  def set_commonly_selected_client
    @common_client = current_user.commonly_selected_clients.find_by!(client_id: params[:id])
  end
end
