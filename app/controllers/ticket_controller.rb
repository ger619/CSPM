class TicketController < ApplicationController
  before_action :authenticate_user! # This line ensures that the user is authenticated before any action is taken
  before_action :set_post

  def create
    @ticket = @project.ticket.new(ticket_params)
    @ticket.user = current_user

    if @ticket.save
      flash[:notice] = 'Ticket was successfully created.'
      redirect_to project_path(@project)
    else
      redirect_to project_path(@project), alert: 'Ticket was not created.'
    end
  end

  def new
    @ticket = @project.ticket.new
  end

  def destroy
    @ticket = @project.ticket.find(params[:id])
    @ticket.destroy
    redirect_to project_path(@project)
  end

  def set_post
    @project = Project.find(params[:project_id])
  end

  private

  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :body)
  end
end
