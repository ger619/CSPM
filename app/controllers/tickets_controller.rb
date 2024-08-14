class TicketsController < ApplicationController
  before_action :authenticate_user! # This line ensures that the user is authenticated before any action is taken
  before_action :set_project
  before_action :set_ticket, only: %i[show destroy edit update]

  def index; end

  def show
    @issue = @ticket.issues.order('created_at DESC')
  end

  def new
    @ticket = @project.tickets.new
  end

  def create
    @tickets = @project.tickets.new(ticket_params)
    @tickets.user = current_user

    if @tickets.save
      flash[:notice] = 'ticket was successfully created.'
      redirect_to project_path(@project)
    else
      redirect_to new_project_path(@project), alert: 'ticket was not created.'
    end
  end

  def destroy
    @ticket = @project.tickets.find(params[:id])
    @ticket.destroy
    redirect_to project_path(@project)
  end

  def edit; end

  def update
    @ticket = @project.tickets.find(params[:id])
    @ticket.user = current_user # Optional: If you want to ensure the user is always the current user

    if @ticket.update(ticket_params)
      flash[:notice] = 'Ticket was successfully updated.'
      redirect_to project_path(@project)
    else
      render :edit, alert: 'Ticket was not updated.'
    end
  end

  private

  def set_project
    @project = Project.friendly.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :start_date, :body, :project_id, :user_id, :image)
  end
end
