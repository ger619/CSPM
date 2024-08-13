class TicketsController < ApplicationController
  before_action :authenticate_user! # This line ensures that the user is authenticated before any action is taken
  before_action :set_project

  def index
    @tickets = @project.tickets.search(params[:query]).order('created_at DESC')
  end

  def show
    @ticket = @project.tickets.find(params[:id])
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
      redirect_to project_path(@project), alert: 'ticket was not created.'
    end
  end

  def destroy
    @ticket = @project.tickets.find(params[:id])
    @comment.destroy
    redirect_to project_path(@project)
  end

  private

  def set_project
    @project = Project.friendly.find(params[:project_id])
  end

  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :body, :project_id, :user_id)
  end
end
