class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_ticket, only: %i[show destroy edit assign_tag unassign_tag add_status]
  load_and_authorize_resource

  def show
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
    @assigned_users = @ticket.users.any?
    @sla_ticket = SlaTicket.find_by(ticket_id: @ticket.id)
  end

  def new
    # Find the 'Client Confirmation Pending' status ID
    confirmation_pending_status = Status.find_by(name: 'Client Confirmation Pending')

    # Count tickets created by the current user with 'Client Confirmation Pending' status
    @tickets_count = if confirmation_pending_status
                       @project.tickets
                         .where(user: current_user)
                         .joins(:statuses)
                         .where(statuses: { id: confirmation_pending_status.id })
                         .count
                     else
                       0
                     end

    # Check if the current user is a client and has 2 or more tickets pending confirmation
    if current_user.has_role?(:client) && @tickets_count >= 10
      redirect_to project_path(@project), flash: { prompt: 'Please confirm past tickets requiring confirmation before creating a new one.' }
      return
    end

    # Initialize a new ticket if the conditions above are not met
    @ticket = @project.tickets.new
  end

  def create
    @ticket = @project.tickets.new(ticket_params)
    @ticket.user = current_user

    respond_to do |format|
      # Custom validations
      %i[content issue priority software_id groupware_id].each do |attribute|
        @ticket.errors.add(attribute, "#{attribute.to_s.humanize} cannot be blank.") if @ticket.public_send(attribute).blank?
      end
      # Handle validation errors or proceed with save
      if @ticket.errors.any? || !@ticket.save
        format.html { render :new, status: :unprocessable_entity }
      else
        # Assign the project manager if no agents are assigned
        @ticket.users << @project.user if @ticket.users.empty?
        status = Status.find_by(name: 'New')
        @ticket.statuses << status if status

        assigned_user = @project.user
        if assigned_user.present?
          UserMailer.create_ticket_email(@ticket, current_user, assigned_user).deliver_later
        else
          Rails.logger.warn('Assigned user is nil, email not sent.')
        end

        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully created.' }
      end
    end
  end

  def destroy
    @ticket.destroy
    redirect_to project_path(@project)
  end

  def edit; end

  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        current_user.add_role :editor, @ticket

        # Assign the project manager if no agents are assigned
        @ticket.users << @project.user if @ticket.users.empty?

        format.html { redirect_to project_path(@project.id), notice: 'Ticket was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Ticket was not updated.' }
      end
    end
  end

  def assign_tag
    if @ticket.users.include?(User.find(params[:user_id]))
      redirect_to project_tickets_path(@ticket), notice: 'User has already been assigned.'
    else
      @ticket.user = current_user
      user = User.find(params[:user_id])

      # Filter out users who have the role of creator
      creator = @ticket.users.select { |u| u.has_role?(:creator, @ticket) }

      # Clear users except the creators
      @ticket.users = creator

      # Add the new user
      @ticket.users << user unless @ticket.users.include?(user)

      assigned_user = user

      # Adding the SLA to the ticket
      SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla_ticket|
        sla_ticket.sla_status = @ticket.sla_status
      end

      UserMailer.ticket_assignment_email(user, @ticket, current_user, assigned_user).deliver_later

      @project.users.each do |project_user|
        next if project_user == current_user

        UserMailer.ticket_assignment_email(project_user, @ticket, current_user, assigned_user).deliver_later
      end
      redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully assigned.'
    end
  end

  def unassign_tag
    @ticket.users.delete(User.find(params[:user_id]))
    redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully unassigned.'
  end

  def add_status
    status = Status.find(params[:status_id])

    if status.nil?
      respond_to do |format|
        format.html { redirect_to project_ticket_path(@project, @ticket), alert: 'Invalid status ID' }
      end
      return
    end

    @ticket.statuses.clear
    @ticket.statuses << status

    if status.name == 'Client Confirmation Pending'
      sla_ticket = SlaTicket.find_or_initialize_by(ticket_id: @ticket.id)
      sla_ticket.update(sla_target_response_deadline: @ticket.sla_target_response_deadline)
    end

    if status.name == 'Resolved'
      sla_ticket = SlaTicket.find_by(ticket_id: @ticket.id)
      if sla_ticket
        sla_ticket.update(sla_resolution_deadline: @ticket.sla_resolution_deadline)
      else
        Rails.logger.warn("SlaTicket not found for ticket_id: #{@ticket.id}")
      end
    end

    @ticket.users.each do |ticket_user|
      UserMailer.status_update_email(ticket_user, @ticket, current_user).deliver_later
    end
    if status.name.in?(['Awaiting Build', 'On-Hold', 'Closed', 'Declined', 'Reopened', 'QA Testing', 'Under Development', 'Work in Progress',
                        'Client Confirmation Pending'])
      redirect_to new_project_ticket_comment_path(@project, @ticket)
    else
      redirect_to project_ticket_path(@project, @ticket), notice: 'Status was successfully assigned.'
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
    params.require(:ticket).permit(:issue, :priority, :content, :project_id, :user_id, :ticket_image,
                                   :status, :status_id, :software_id, :groupware_id,
                                   :subject, user_ids: [], attachments: [])
  end
end
