class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_ticket, only: %i[show destroy edit assign_tag unassign_tag add_status]
  load_and_authorize_resource

  def show
    @issue = fetch_issues
    @comment = fetch_comments
    @assigned_users = @ticket.users.any?
    @sla_ticket = SlaTicket.find_by(ticket_id: @ticket.id)
    @events = @ticket.events.order(created_at: :asc)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    confirmation_pending_status = Status.find_by(name: 'Client Confirmation Pending')
    @tickets_count = count_pending_tickets(confirmation_pending_status)

    if current_user.has_role?(:client) && @tickets_count >= 10
      redirect_to project_path(@project),
                  flash: { prompt: 'You can have a maximum of 10 pending tickets. Please resolve at least one ticket under "Client Pending Confirmation" to proceed.' }
      return
    end

    @ticket = @project.tickets.new
    @softwares = @project.softwares
    @groupwares = fetch_groupwares
  end

  def create
    @ticket = @project.tickets.new(ticket_params)
    @ticket.user = current_user

    respond_to do |format|
      if validate_ticket && @ticket.save
        assign_users_to_ticket
        set_sla_for_ticket
        send_creation_email
        log_event(@ticket, current_user, 'created and assign', "Ticket was created and assigned to #{@project.user.name}")

        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
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
        UpdateHistory.record_update(@ticket, current_user, @ticket.saved_changes.except(:updated_at))
        set_sla_for_ticket
        log_event(@ticket, current_user, 'update', 'Ticket was updated.')

        format.html { redirect_to project_path(@project.id), notice: 'Ticket was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Ticket was not updated.' }
      end
    end
  end

  def assign_tag
    user = User.find(params[:user_id])
    if @ticket.users.include?(user)
      redirect_to project_tickets_path(@ticket), notice: 'User has already been assigned.'
    else
      assign_user_to_ticket(user)
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
      redirect_to project_ticket_path(@project, @ticket), alert: 'Invalid status ID'
      return
    end

    update_ticket_status(status)
    log_event(@ticket, current_user, 'status_change', "Status was changed to #{status.name}")

    if status.name.in?(%w[Resolved Closed Declined Reopened])
      redirect_to new_project_ticket_comment_path(@project, @ticket)
    else
      redirect_to project_ticket_path(@project, @ticket), notice: 'Status was successfully assigned.'
    end
  end

  def update_due_date
    update_ticket_attribute(:due_date, params[:ticket][:due_date], 'Due date updated successfully.', 'Failed to update due date.')
  end

  def update_priority
    update_ticket_attribute(:priority, params[:ticket][:priority], 'Priority updated successfully.', 'Failed to update priority.')
  end

  def update_issue_type
    update_ticket_attribute(:issue, params[:ticket][:issue], 'Issue type updated successfully.', 'Failed to update issue type.')
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

  def fetch_issues
    if params[:query].present?
      @ticket.issues.left_joins(:rich_text_content).where('action_text_rich_texts.body ILIKE ?', "%#{params[:query]}%")
    else
      @ticket.issues.with_rich_text_content.order('created_at DESC')
    end.paginate(page: params[:issue_page], per_page: 5)
  end

  def fetch_comments
    @ticket.comments.with_rich_text_content.order('created_at DESC').paginate(page: params[:comment_page], per_page: 5)
  end

  def count_pending_tickets(status)
    return 0 unless status

    @project.tickets.where(user: current_user).joins(:statuses).where(statuses: { id: status.id }).count
  end

  def fetch_groupwares
    if @ticket.software_id.present?
      @project.groupwares.joins(:softwares).where(softwares: { id: @ticket.software_id }).distinct
    else
      @project.groupwares.distinct
    end
  end

  def validate_ticket
    %i[content issue priority software_id groupware_id].each do |attribute|
      @ticket.errors.add(attribute, "#{attribute.to_s.humanize} cannot be blank.") if @ticket.public_send(attribute).blank?
    end
    @ticket.errors.empty?
  end

  def assign_users_to_ticket
    if @ticket.groupware_id.present?
      groupware = Groupware.find(@ticket.groupware_id)
      tagged_user = groupware.user
      @ticket.users << (tagged_user.present? && @project.users.include?(tagged_user) ? tagged_user : @project.user)
    elsif @ticket.users.empty?
      @ticket.users << @project.user
    end
  end

  def set_sla_for_ticket
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
  end

  def send_creation_email
    assigned_user = @project.user
    if assigned_user.present?
      UserMailer.create_ticket_email(@ticket, current_user, assigned_user, @project).deliver_later
    else
      Rails.logger.warn('Assigned user is nil, email not sent.')
    end
  end

  def assign_user_to_ticket(user)
    @ticket.user = current_user
    @ticket.users.clear
    @ticket.users << user

    Notification.create!(user: user, ticket: @ticket, message: 'A new ticket has been assigned to you.', read: false)
    SlaTicket.find_or_create_by!(ticket_id: @ticket.id) { |sla| sla.sla_status = @ticket.sla_status }

    UserMailer.ticket_assignment_email(user, @project, @ticket, current_user, user).deliver_later
    log_event(@ticket, current_user, 'assign',
              "#{user.name} was assigned to the ticket, with Status: #{@ticket.sla_status} and Target Response Deadline
                      #{@ticket.sla_target_response_deadline.presence || 'Not Breached'}")
  end

  def update_ticket_status(status)
    @ticket.statuses.clear
    @ticket.statuses << status

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

    send_status_update_emails(status)
  end

  def send_status_update_emails(status)
    if status.name == 'Reopened'
      @project.users.each { |user| UserMailer.status_update_email(user, @ticket, current_user, @project).deliver_later }
      UserMailer.status_update_email(@project.user, @ticket, current_user, @project).deliver_later if @project.user
      UserMailer.status_update_email(@ticket.users.first, @ticket, current_user, @project).deliver_later if @ticket.users.first
    else
      @ticket.users.each { |user| UserMailer.status_update_email(user, @ticket, current_user, @project).deliver_later }
      UserMailer.status_update_email(@ticket.user, @ticket, current_user, @project).deliver_later unless @ticket.users.include?(@ticket.user)
    end
  end

  def update_ticket_attribute(attribute, value, success_message, failure_message)
    if @ticket.update(attribute => value)
      respond_to do |format|
        format.js
        format.html { redirect_back fallback_location: project_ticket_path(@project, @ticket), notice: success_message }
      end
    else
      respond_to do |format|
        format.js
        format.html { render :edit, alert: failure_message }
      end
    end
  end
end
