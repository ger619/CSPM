class TicketsController < ApplicationController
  # Ensure user is authenticated for all actions
  before_action :authenticate_user!
  # Set the current project for all actions
  before_action :set_project
  # Set the ticket for specific actions
  before_action :set_ticket, only: %i[show destroy edit assign_tag unassign_tag add_status]
  # Load and authorize resources using CanCanCan
  load_and_authorize_resource

  # Show a single ticket with issues, comments, and events
  def show
    # Search issues by rich text content if query is present, else show all issues
    @issue = if params[:query].present?
               @ticket.issues.left_joins(:rich_text_content)
                 .where('action_text_rich_texts.body ILIKE ?', "%#{params[:query]}%")
             else
               @ticket.issues.with_rich_text_content.order('created_at DESC')
             end

    # Get all comments with rich text, ordered by creation date
    @comment = @ticket.comments.with_rich_text_content.order('created_at DESC')

    # Check if any users are assigned to the ticket
    @assigned_users = @ticket.users.any?
    # Get the SLA record for this ticket
    @sla_ticket = SlaTicket.find_by(ticket_id: @ticket.id)
    # Get all events for this ticket
    @events = @ticket.events.order(created_at: :asc)

    # Combine issues and comments, sort by creation date (descending), and paginate
    ticket_items = (@ticket.issues + @ticket.comments).sort_by(&:created_at).reverse
    @page = (params[:ticket_items_page] || 1).to_i
    per_page = 10
    @total_pages = (ticket_items.size / per_page.to_f).ceil
    @ticket_items = ticket_items.slice((@page - 1) * per_page, per_page) || []

    # Respond to HTML or JS (AJAX) requests
    respond_to do |format|
      format.html
      format.js
    end
  end

  # Render form for new ticket
  def new
    # Find the status for 'Client Confirmation Pending'
    confirmation_pending_status = Status.find_by(name: 'Client Confirmation Pending')

    # Count how many tickets the current user has in that status
    @tickets_count = if confirmation_pending_status
                       @project.tickets
                         .where(user: current_user)
                         .joins(:statuses)
                         .where(statuses: { id: confirmation_pending_status.id })
                         .count
                     else
                       0
                     end

    # Prevent clients from creating more than 10 pending tickets
    if current_user.has_role?(:client) && @tickets_count >= 10
      redirect_to project_path(@project),
                  flash: { prompt: 'You can have a maximum of 10 pending tickets. Please resolve at least one ticket under "Client Pending Confirmation" to proceed.' }
      return
    end

    # Initialize a new ticket for the form
    @ticket = @project.tickets.new
    # Get all softwares for the project
    @softwares = @project.softwares

    # Get groupwares for the selected software, or all if none selected
    @groupwares = if @ticket.software_id.present?
                    @project.groupwares
                      .joins(:softwares)
                      .where(softwares: { id: @ticket.software_id })
                      .distinct
                  else
                    @project.groupwares.distinct
                  end
  end

  # Create a new ticket
  def create
    @ticket = @project.tickets.new(ticket_params)
    @ticket.user = current_user

    respond_to do |format|
      # Custom validations for required fields
      %i[content issue priority software_id groupware_id].each do |attribute|
        @ticket.errors.add(attribute, "#{attribute.to_s.humanize} cannot be blank.") if @ticket.public_send(attribute).blank?
      end

      # If validation fails or save fails, re-render form
      if @ticket.errors.any? || !@ticket.save
        format.html { render :new, status: :unprocessable_entity }
      else
        # Assign tagged user or default project user
        if @ticket.groupware_id.present?
          groupware = Groupware.find(@ticket.groupware_id)
          tagged_user = groupware.user
          @ticket.users << if tagged_user.present? && @project.users.include?(tagged_user)
                             tagged_user
                           else
                             @project.user
                           end
        elsif @ticket.users.empty?
          @ticket.users << @project.user
        end

        # Set SLA for new feature or regular ticket
        if @ticket.issue == 'NEW FEATURE'
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

        # Send notification email to assigned user
        assigned_user = @project.user
        if assigned_user.present?
          UserMailer.create_ticket_email(@ticket, current_user, assigned_user, @project).deliver_later
        else
          Rails.logger.warn('Assigned user is nil, email not sent.')
        end

        # Log the creation event
        log_event(@ticket, current_user, 'created and assign', "Ticket was created and assigned to #{assigned_user.name} at #{Time.now.strftime('%H:%M of  %d-%m-%Y')}")
        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully created.' }
      end
    end
  end

  # Delete a ticket
  def destroy
    log_event(@ticket, current_user, 'destroy', 'Ticket was destroyed.')
    @ticket.destroy
    redirect_to project_path(@project)
  end

  # Render edit form (logic handled in view)
  def edit; end

  # Update a ticket
  def update
    respond_to do |format|
      if @ticket.update(ticket_params)
        # Add editor role to current user for this ticket
        current_user.add_role :editor, @ticket
        # Log update history if not skipped
        if request.patch? && !@ticket.skip_history_logging
          change_details = @ticket.saved_changes.except(:updated_at)
          UpdateHistory.record_update(@ticket, current_user, change_details)
        end

        # Set SLA for new feature or regular ticket
        if @ticket.issue == 'NEW FEATURE'
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

        # Send notification emails to relevant users
        assigned_user = @project.user
        ticket_user = @ticket.user
        user = @ticket.users.first

        if assigned_user.present?
          UserMailer.edit_ticket_email(user, @ticket, current_user, assigned_user, @project).deliver_later
        else
          Rails.logger.warn('Assigned project user is nil, email not sent.')
        end

        if ticket_user.present? && ticket_user != assigned_user && ticket_user != user
          UserMailer.edit_ticket_email(user, @ticket, current_user, ticket_user, @project).deliver_later
        else
          Rails.logger.warn('Assigned ticket user is nil or already notified, email not sent.')
        end

        if user.present? && user != ticket_user && user != assigned_user
          UserMailer.edit_ticket_email(user, @ticket, current_user, user, @project).deliver_later
        else
          Rails.logger.warn('User is nil or already notified, email not sent.')
        end

        # Log the update event
        log_event(@ticket, current_user, 'update', "Ticket was updated. at #{Time.now.strftime('%H:%M of  %d-%m-%Y')}")
        format.html { redirect_to project_path(@project.id), notice: 'Ticket was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Ticket was not updated.' }
      end
    end
  end

  # Assign a user to a ticket
  def assign_tag
    if @ticket.users.include?(User.find(params[:user_id]))
      redirect_to project_tickets_path(@ticket), notice: 'User has already been assigned.'
    else
      @ticket.user = current_user
      user = User.find(params[:user_id])

      # Remove all users and assign the new one
      @ticket.users.clear
      @ticket.users << user
      assigned_user = user

      # Create a notification for the assigned user
      Notification.create!(
        user: assigned_user,
        ticket: @ticket,
        message: 'A new ticket has been assigned to you.',
        read: false
      )

      # Set SLA for the ticket
      sla_ticket = SlaTicket.find_or_create_by!(ticket_id: @ticket.id) do |sla|
        sla.sla_status = @ticket.sla_status
      end

      # Set default SLA target response deadline if blank
      sla_target_response_deadline = sla_ticket.sla_target_response_deadline.presence || 'Not Breached'

      # Log SLA details
      Rails.logger.info("SlaTicket details: #{sla_ticket.attributes}, SLA Status: #{sla_ticket.sla_status}")

      # Send assignment email
      UserMailer.ticket_assignment_email(user, @project, @ticket, current_user, assigned_user).deliver_later

      # Log the assignment event
      log_event(@ticket, current_user, 'assign', "#{user.name} was assigned to the ticket, with Status:
        #{sla_ticket.sla_status} and Target Response Deadline #{sla_target_response_deadline}")
      redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully assigned.'
    end
  end

  # Unassign a user from a ticket
  def unassign_tag
    user = User.find(params[:user_id])
    @ticket.users.delete(user)
    log_event(@ticket, current_user, 'unassign', "#{user.name} was unassigned from the ticket.")
    redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully unassigned.'
  end

  # Change the status of a ticket
  def add_status
    status = Status.find(params[:status_id])

    if status.nil?
      respond_to do |format|
        format.html { redirect_to project_ticket_path(@project, @ticket), alert: 'Invalid status ID' }
      end
      return
    end

    # Clear all statuses and set the new one
    @ticket.statuses.clear
    @ticket.statuses << status

    # Update SLA deadlines for certain statuses
    if status.name == 'Client Confirmation Pending'
      sla_ticket = SlaTicket.find_or_initialize_by(ticket_id: @ticket.id)
      sla_ticket.update(sla_target_response_deadline: @ticket.sla_target_response_deadline)
    end

    if status.name == 'Resolved'
      sla_ticket = SlaTicket.find_by(ticket_id: @ticket.id)
      if sla_ticket
        assigned_user = @ticket.users.first
        sla_ticket.update(sla_resolution_deadline: @ticket.sla_resolution_deadline, user_id: assigned_user.id)
      else
        Rails.logger.warn("SlaTicket not found for ticket_id: #{@ticket.id}")
      end
    end

    # Send status update emails
    if status.name != 'Reopened'
      @ticket.users.each do |ticket_user|
        UserMailer.status_update_email(ticket_user, @ticket, current_user, @project).deliver_later
      end
    end

    if status.name == 'Reopened'
      @project.users.each do |project_user|
        UserMailer.status_update_email(project_user, @ticket, current_user, @project).deliver_later
      end
    end

    # Log the status change event
    log_event(@ticket, current_user, 'status_change', "Status was changed to #{status.name}")

    # Redirect to comment form for certain statuses, else back to ticket
    if status.name.in?(%w[Resolved Closed Declined Reopened])
      redirect_to new_project_ticket_comment_path(@project, @ticket)
    else
      redirect_to project_ticket_path(@project, @ticket), notice: 'Status was successfully assigned.'
    end
  end

  # Update the due date of a ticket
  def update_due_date
    @ticket = Ticket.find(params[:id])
    @ticket.skip_history_logging = false
    if @ticket.update(due_date: params[:ticket][:due_date])
      if request.patch? && !@ticket.skip_history_logging
        change_details = @ticket.saved_changes.except(:updated_at)
        UpdateHistory.record_update(@ticket, current_user, change_details)
      end
      respond_to do |format|
        format.js
        format.html { redirect_back fallback_location: project_ticket_path(@project, @ticket), notice: 'Due date updated successfully.' }
      end
    else
      respond_to do |format|
        format.js
        format.html { render :edit, alert: 'Failed to update due date.' }
      end
    end
  end

  # Update the priority of a ticket
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

  # List closed tickets from the last week (admin/internal only)
  def closed_tickets_one_week
    @tickets = Ticket.joins(:statuses, :project).where(statuses: { name: 'Closed' })
      .where('tickets.created_at >= ?', 1.week.ago)
      .distinct
    @per_page = 20
    @page = (params[:page] || 1).to_i
    @total_pages = (@tickets.count / @per_page.to_f).ceil
    @tickets = @tickets.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # List all tickets created in the last week
  def created_tickets_one_week
    @tickets = Ticket.joins(:statuses, :project)
      .where('tickets.created_at >= ?', 1.week.ago)
      .distinct
    @per_page = 20
    @page = (params[:page] || 1).to_i
    @total_pages = (@tickets.count / @per_page.to_f).ceil
    @tickets = @tickets.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # List all open tickets (not closed, resolved, or declined)
  def all_open_tickets
    @tickets = Ticket.joins(:statuses, :project)
      .where.not(statuses: { name: %w[Closed Resolved Declined] })
      .distinct
    @per_page = 50
    @page = (params[:page] || 1).to_i
    @total_pages = (@tickets.count / @per_page.to_f).ceil
    @tickets = @tickets.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # List open tickets for the current user
  def index
    @tickets = current_user.tickets.joins(:statuses)
      .where.not(statuses: { name: %w[Closed Resolved Declined] })
      .distinct
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@tickets.count / @per_page.to_f).ceil
    @tickets = @tickets.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # List all open tickets for all projects the user is part of
  def all_tickets
    @projects = current_user.projects
    @tickets = Ticket.joins(:statuses, :project)
      .where(projects: { id: @projects.ids })
      .where.not(statuses: { name: %w[Closed Resolved Declined] })
      .order('created_at DESC')
      .distinct
    @per_page = 20
    @page = (params[:page] || 1).to_i
    @total_pages = (@tickets.count / @per_page.to_f).ceil
    @tickets = @tickets.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # Update the issue type of a ticket
  def update_issue_type
    @ticket = Ticket.find(params[:id])
    @ticket.skip_sla_callbacks = true

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

  # List tickets with non-breached SLA for a project
  def non_breached_sla_tickets
    @project = Project.find(params[:project_id])
    @tickets = @project.tickets.joins(:sla_tickets).where("sla_tickets.sla_status = 'Not Breached'")
  end

  private

  # Set the current project from params
  def set_project
    @project = Project.find(params[:project_id])
  end

  # Set the current ticket from params
  def set_ticket
    @ticket = @project.tickets.find(params[:id])
  end

  # Strong parameters for ticket creation/updating
  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :content, :project_id, :user_id, :ticket_image,
                                   :status, :status_id, :software_id, :groupware_id, :unique_id, :due_date,
                                   :subject, user_ids: [], attachments: [])
  end

  # Log an event for auditing
  def log_event(ticket, user, event_type, details)
    Event.create(ticket: ticket, user: user, event_type: event_type, details: details)
  end
end
