class TicketsController < ApplicationController
  before_action :authenticate_user! # This line ensures that the user is authenticated before any action is taken
  before_action :set_project # This line ensures that the project is set before any action is taken
  # This line ensures that the ticket is set before any action is taken
  before_action :set_ticket, only: %i[show destroy edit update assign_tag unassign_tag update_status]

  def index; end

  def show
    # Issues search this code is used to search for issues in the ticket
    @issue = if params[:query].present?
               @ticket.issues.left_joins(:rich_text_body).where('action_text_rich_texts.body ILIKE ?',
                                                                "%#{params[:query]}%")

             else
               @ticket.issues.with_rich_text_body.order('created_at DESC')
             end
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@issue.count / @per_page.to_f).ceil
    @issue = @issue.offset((@page - 1) * @per_page).limit(@per_page)
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
      @ticket.users << user
      UserMailer.ticket_assignment_email(user, @ticket, current_user).deliver_now
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

  def update_status
    @ticket = @project.tickets.find(params[:id])
    @ticket.user = current_user # O
    if @ticket.update(ticket_params)
      @ticket.users.each do |ticket_user|
        UserMailer.status_update_email(ticket_user, @ticket, current_user).deliver_now
      end
      respond_to do |format|
        format.html { redirect_to project_tickets_path(@ticket), notice: 'Status updated successfully' }
      end
    else
      respond_to do |format|
        format.html { redirect_to project_tickets_path(@ticket), alert: 'Failed to update status' }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :start_date, :body, :project_id, :user_id, :ticket_image,
                                   :status, user_ids: [])
  end
end
