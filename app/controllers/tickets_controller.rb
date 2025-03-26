class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_ticket, only: %i[show destroy edit assign_tag unassign_tag add_status]
  load_and_authorize_resource

  def show
    # Handling issues with rich text content and search query
    @issue = if params[:query].present?
               @ticket.issues.left_joins(:rich_text_content)
                 .where('action_text_rich_texts.body ILIKE ?', "%#{params[:query]}%")
             else
               @ticket.issues.with_rich_text_content.order('created_at DESC')
             end

    # Handling comments with pagination
    @comment = @ticket.comments.with_rich_text_content.order('created_at DESC')
    @per_page2 = 5
    @page2 = (params[:comment_page] || 1).to_i # Use `comment_page` for comments pagination to differentiate from issues
    @total_pages2 = (@comment.count / @per_page2.to_f).ceil
    @comment = @comment.offset((@page2 - 1) * @per_page2).limit(@per_page2)

    # Other variables
    @assigned_users = @ticket.users.any?
    @sla_ticket = SlaTicket.find_by(ticket_id: @ticket.id)
    @events = @ticket.events.order(created_at: :asc)

    @ticket_items = (@ticket.issues + @ticket.comments).sort_by(&:created_at).reverse

    # Respond to HTML and JS requests
    respond_to do |format|
      format.html # Default behavior: render the full page
      format.js # AJAX request: render only the necessary partials
    end
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

    # Check if the current user is a client and has 10 or more tickets pending confirmation
    if current_user.has_role?(:client) && @tickets_count >= 10
      redirect_to project_path(@project),
                  flash: { prompt: 'You can have a maximum of 10 pending tickets. Please resolve at least one ticket under "Client Pending Confirmation" to proceed.' }
      return
    end

    @ticket = @project.tickets.new

    # Fetch associated softwares for the project
    @softwares = @project.softwares

    # Fetch groupwares associated with the project and the selected software
    # If a software_id is already selected, filter groupwares accordingly
    @groupwares = if @ticket.software_id.present?
                    @project.groupwares
                      .joins(:softwares)
                      .where(softwares: { id: @ticket.software_id })
                      .distinct
                  else
                    # If no software is selected, load all groupwares for the project
                    @project.groupwares
                      .distinct
                  end
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
        if @ticket.groupware_id.present?
          groupware = Groupware.find(@ticket.groupware_id)
          tagged_user = groupware.user
          # Assign the tagged user if present and part of the project
          @ticket.users << if tagged_user.present? && @project.users.include?(tagged_user)
                             tagged_user
                           else
                             # Assign the default user if tagged user is not part of the project
                             @project.user
                           end
        elsif @ticket.users.empty?
          @ticket.users << @project.user
        end

        if @ticket.issue == 'NEW FEATURE'
          # Set all SLAs to 'NO SLA' for new feature
          SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla|
            sla.sla_status = 'NO SLA'
            sla.sla_target_response_deadline = 'NO SLA'
            sla.sla_resolution_deadline = 'NO SLA'
          end
        else
          SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla_ticket|
            sla_ticket.sla_status = @ticket.sla_status
          end
        end

        assigned_user = @project.user
        if assigned_user.present?
          UserMailer.create_ticket_email(@ticket, current_user, assigned_user, @project).deliver_later
        else
          Rails.logger.warn('Assigned user is nil, email not sent.')
        end

        log_event(@ticket, current_user, 'created and assign', "Ticket was created and assigned to #{assigned_user.name}")

        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully created.' }
      end
    end
  end

  def destroy
    log_event(@ticket, current_user, 'destroy', 'Ticket was destroyed.')
    @ticket.destroy
    redirect_to project_path(@project)
  end

  def edit; end

  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        current_user.add_role :editor, @ticket
        change_details = @ticket.saved_changes.except(:updated_at)
        UpdateHistory.record_update(@ticket, current_user, change_details)

        # Assign the project manager if no agents are assigned
        # Check if groupware_id is present
        # if @ticket.groupware_id.present?
        #  groupware = Groupware.find(@ticket.groupware_id)
        #  tagged_user = groupware.user

        # Assign the tagged user if present
        #  @ticket.users << tagged_user if tagged_user.present?
        # elsif @ticket.users.empty?
        #  @ticket.users << @project.user
        # end

        # Assign the default user if no users are assigned

        if @ticket.issue == 'NEW FEATURE'
          # Set all SLAs to 'NO SLA' for new feature
          SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla|
            sla.sla_status = 'NO SLA'
            sla.sla_target_response_deadline = 'NO SLA'
            sla.sla_resolution_deadline = 'NO SLA'
          end
        else
          SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla_ticket|
            sla_ticket.sla_status = @ticket.sla_status
          end
        end

        log_event(@ticket, current_user, 'update', 'Ticket was updated.')

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

      # Clear all users from the ticket
      @ticket.users.clear

      # Add the new user
      @ticket.users << user

      assigned_user = user

      Notification.create!(
        user: assigned_user, # Use assigned_user here to send the notification
        ticket: @ticket,
        message: 'A new ticket has been assigned to you.',
        read: false
      )

      # Adding the SLA to the ticket
      sla_ticket = SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla|
        sla.sla_status = @ticket.sla_status
      end

      # Check if sla_target_response_deadline is blank and set to 'not breached' if it is
      sla_target_response_deadline = sla_ticket.sla_target_response_deadline.presence || 'Not Breached'

      # Log the details of the SlaTicket including the SLA status
      Rails.logger.info("SlaTicket details: #{sla_ticket.attributes}, SLA Status: #{sla_ticket.sla_status}")

      UserMailer.ticket_assignment_email(user, @project, @ticket, current_user, assigned_user).deliver_later

      log_event(@ticket, current_user, 'assign', "#{user.name} was assigned to the ticket, with Status:
        #{sla_ticket.sla_status} and Target Response Deadline #{sla_target_response_deadline}")
      redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully assigned.'
    end
  end

  def unassign_tag
    user = User.find(params[:user_id])
    @ticket.users.delete(user)
    log_event(@ticket, current_user, 'unassign', "#{user.name} was unassigned from the ticket.")
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
        assigned_user = @ticket.users.first # Pick the first assigned user on the ticket
        sla_ticket.update(sla_resolution_deadline: @ticket.sla_resolution_deadline, user_id: assigned_user.id)
      else
        Rails.logger.warn("SlaTicket not found for ticket_id: #{@ticket.id}")
      end
    end

    if status.name != 'Reopened'
      @ticket.users.each do |ticket_user|
        UserMailer.status_update_email(ticket_user, @ticket, current_user, @project).deliver_later
      end
      UserMailer.status_update_email(@ticket.user, @ticket, current_user, @project).deliver_later unless @ticket.users.include?(@ticket.user)
    end

    if status.name == 'Reopened'
      @project.users.each do |project_user|
        UserMailer.status_update_email(project_user, @ticket, current_user, @project).deliver_later
      end

      # Send email to the person assigned to the project
      project_assigned_user = @project.user
      UserMailer.status_update_email(project_assigned_user, @ticket, current_user, @project).deliver_later if project_assigned_user

      # Send email to the person assigned to the ticket
      ticket_assigned_user = @ticket.users.first
      UserMailer.status_update_email(ticket_assigned_user, @ticket, current_user, @project).deliver_later if ticket_assigned_user
    end

    log_event(@ticket, current_user, 'status_change', "Status was changed to #{status.name}")

    if status.name.in?(%w[Resolved Closed Declined Reopened])
      redirect_to new_project_ticket_comment_path(@project, @ticket)
    else
      redirect_to project_ticket_path(@project, @ticket), notice: 'Status was successfully assigned.'
    end
  end

  def update_due_date
    @ticket = Ticket.find(params[:id])
    if @ticket.update(due_date: params[:ticket][:due_date])
      respond_to do |format|
        format.js # To update via AJAX
        format.html { redirect_back fallback_location: project_ticket_path(@project, @ticket), notice: 'Due date updated successfully.' }
      end
    else
      respond_to do |format|
        format.js # To handle errors via AJAX
        format.html { render :edit, alert: 'Failed to update due date.' }
      end
    end
  end

  def update_priority
    @ticket = Ticket.find(params[:id])

    if @ticket.update(priority: params[:ticket][:priority])
      respond_to do |format|
        format.js
        format.html { redirect_to project_ticket_path(@ticket.project, @ticket), notice: 'Priority updated successfully.' }
      end
    else
      respond_to do |format|
        format.js
        format.html { render :edit, alert: 'Failed to update priority.' }
      end
    end
  end

  def update_issue_type
    @ticket = Ticket.find(params[:id])

    if @ticket.update(issue: params[:ticket][:issue])
      respond_to do |format|
        format.js
        format.html { redirect_to project_ticket_path(@ticket.project, @ticket), notice: 'Issue type updated successfully.' }
      end
    else
      respond_to do |format|
        format.js
        format.html { render :edit, alert: 'Failed to update issue type.' }
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
    params.require(:ticket).permit(:issue, :priority, :content, :project_id, :user_id, :ticket_image,
                                   :status, :status_id, :software_id, :groupware_id, :unique_id, :due_date,
                                   :subject, user_ids: [], attachments: [])
  end

  def log_event(ticket, user, event_type, details)
    Event.create(ticket: ticket, user: user, event_type: event_type, details: details)
  end
end
