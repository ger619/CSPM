class TicketsController < ApplicationController
  before_action :authenticate_user! # This line ensures that the user is authenticated before any action is taken
  before_action :set_project # This line ensures that the project is set before any action is taken
  before_action :set_ticket, only: %i[show destroy edit assign_tag unassign_tag add_status] # This line ensures that
  load_and_authorize_resource

  def index; end

  def show
    # Issues search this code is used to search for issues in the ticket
    @issue = if params[:query].present?
               @ticket.issues.left_joins(:rich_text_content).where('action_text_rich_texts.body ILIKE ?', "%#{params[:query]}%")
             else
               @ticket.issues.with_rich_text_content.order('created_at DESC')
             end

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@issue.count / @per_page.to_f).ceil
    @issue = @issue.offset((@page - 1) * @per_page).limit(@per_page)

    @comment = @ticket.comments.with_rich_text_content.order('created_at DESC')
    # check if the user is assigned to anyone on the ticket
    @assigned_users = @ticket.users.any?
  end

  def new
    @ticket = @project.tickets.new
  end

  def create
    @tickets = @project.tickets.new(ticket_params)
    @tickets.user = current_user

    respond_to do |format|
      if @tickets.save
        current_user.add_role :creator, @tickets
        format.html { redirect_to project_path(@project), notice: 'ticket was successfully created.' }
      else
        # redirect_to new_project_path(@project), alert: 'ticket was not created.'
        format.html { render :new, status: :unprocessable_entity }
      end
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

    respond_to do |format|
      if @ticket.update(ticket_params)
        current_user.add_role :editor, @ticket
        format.html { redirect_to project_path(@project.id), notice: 'Ticket was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Ticket was not updated.' }
      end
    end
  end

  def assign_tag
    # if user is already assigned to the ticket do not assign again
    if @ticket.users.include?(User.find(params[:user_id]))
      redirect_to project_tickets_path(@ticket), notice: 'User has already been assigned .'
    else
      @project = Project.find(params[:project_id])
      @ticket = @project.tickets.find(params[:id])
      @ticket.user = current_user
      user = User.find(params[:user_id])
      @ticket.user

      # Filter out users who have the role of creator
      creator = @ticket.users.select { |u| u.has_role?(:creator, @ticket) }

      # Clear users except the creators
      @ticket.users = creator

      # Add the new user
      @ticket.users << user unless @ticket.users.include?(user)

      assigned_user = user # send an email to all users assigned to the ticket
      UserMailer.ticket_assignment_email(user, @ticket, current_user, assigned_user).deliver_later

      @project.users.each do |project_user|
        next if project_user == current_user

        UserMailer.ticket_assignment_email(project_user, @ticket, current_user, assigned_user).deliver_later
      end
      redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully assigned.'
    end
  end

  def unassign_tag
    @project = Project.find(params[:project_id])
    @ticket = @project.tickets.find(params[:id])
    user = User.find(params[:user_id])
    @ticket.users.delete(user)
    redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully unassigned.'
  end

  def add_status
    @project = Project.find(params[:project_id])
    @ticket = @project.tickets.find(params[:id])
    @ticket.user = current_user
    status = Status.find(params[:status_id])

    if status.nil?
      respond_to do |format|
        format.html { redirect_to project_ticket_path(@project, @ticket), alert: 'Invalid status ID' }
      end
      return
    end

    @ticket.statuses.clear
    @ticket.statuses << status
    @ticket.users.each do |ticket_user|
      UserMailer.status_update_email(ticket_user, @ticket, current_user).deliver_later
    end
    redirect_to project_ticket_path(@project, @ticket), notice: 'Status was successfully assigned.'
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :content, :project_id, :user_id, :ticket_image,
                                   :status, :status_id, user_ids: [])
  end
end
