class CommonlySelectedClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commonly_selected_client, only: [:destroy]

  def index
    @common_clients = current_user.common_clients.order(:name)
  end

  def create
    @common_client = current_user.commonly_selected_clients.new(client_id: params[:client_id])

    if @common_client.save
      redirect_back fallback_location: cease_fire_report_path, notice: "Client was successfully added to your common list."
    else
      redirect_back fallback_location: cease_fire_report_path, alert: @common_client.errors.full_messages.to_sentence
    end
  end

  def destroy
    @common_client.destroy
    redirect_back fallback_location: cease_fire_report_path, notice: "Client was removed from your common list."
  end

  private

  def set_commonly_selected_client
    @common_client = current_user.commonly_selected_clients.find_by!(client_id: params[:id])
  end
end
