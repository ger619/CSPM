class IssuesController < ApplicationController
  before_action :set_project
  before_action :set_ticket
  before_action :set_issue, only: %i[show destroy edit update]

  def index
    @issues = @ticket.issues
  end

  def show; end

  def new
    @issue = @ticket.issues.new
  end

  def create
    @issue = @ticket.issues.new(issue_params)
    @issue.project = @project
    @issue.user = current_user

    respond_to do |format|
      if @issue.save
        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully created.' }
      else
        format.html { redirect_to new_project_ticket_issue_path(@project, @ticket), alert: 'Issue was not created.' }
      end
    end
  end

  def destroy
    @issue = @ticket.issues.find(params[:id])
    @issue.destroy
    redirect_to project_ticket_path(@project, @ticket)
  end

  def edit; end

  def update
    if @issue.update(issue_params)
      redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.friendly.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:ticket_id])
  end

  def set_issue
    @issue = @ticket.issues.find(params[:id])
  end

  def issue_params
    params.require(:issue).permit(:content, :ticket_id, :project_id, :user_id)
  end
end
