require 'csv'
class DataCenterController < ApplicationController
  before_action :authenticate_user!

  def cease_fire_report
    authorize! :generate, :report # Check if the user can generate reports

    @tickets = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                 Ticket.joins(project: :client)
               else
                 Ticket.joins(project: :client).where(projects: { id: current_user.projects.ids })
               end

    @tickets = @tickets.where(projects: { client_id: params[:client_id] }) if params[:client_id].present?

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @tickets = @tickets.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    @tickets = if params[:status].blank?
                 @tickets.joins(:statuses)
               else
                 @tickets.joins(:statuses).where(statuses: { name: params[:status] })
               end

    @status_counts = @tickets.joins(:statuses).group('statuses.name').count

    respond_to do |format|
      format.html # Default view
      client_name = params[:client_id].present? ? Client.find(params[:client_id]).name : 'all_clients'
      filename = "ticket_status_report_#{client_name}_#{Date.today}.csv"
      format.csv { send_data generate_csv(@tickets), filename: filename }
    end
  end

  def breach_report
    authorize! :generate, :report # Check if the user can generate reports

    if params[:client_id].present?
      @tickets = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                   Ticket.joins(project: :client)
                 else
                   Ticket.joins(project: :client).where(projects: { id: current_user.projects.ids })
                 end

      @tickets = @tickets.where(projects: { client_id: params[:client_id] }) if params[:client_id].present?
      @tickets = @tickets.joins(:statuses).where(statuses: { name: params[:status] }) if params[:status].present?
      @tickets = @tickets.where(priority: params[:priority]) if params[:priority].present?

      @status_counts = @tickets.joins(:statuses).group('statuses.name').count

      respond_to do |format|
        format.html # Default view
        client_name = Client.find(params[:client_id]).name if params[:client_id].present?
        format.csv { send_data generate_breach_details_csv(@tickets), filename: "breach__report_for_#{client_name}_#{Date.today}.csv" }
      end
    else
      @tickets = Ticket.none
      flash[:alert] = 'Please provide a valid client.'
      render :breach_report
    end
  end

  # User activity report for the admin
  def user_report
    authorize! :generate, :report # Check if the user can generate reports
    if params[:user_id].present?

      @users = User.includes(tickets: :project)
        .where(id: params[:user_id])

      @status_counts = @users.flat_map(&:tickets).group_by { |ticket| ticket.statuses.first&.name || 'N/A' }.transform_values(&:count)

      respond_to do |format|
        format.html # Default view
        format.csv { send_data generate_user_csv(@users), filename: "user_report_#{Date.today}.csv" }
      end
    else
      @users = User.none
      flash[:alert] = 'Please provide a valid date range.'
      render :user_report
    end
  end

  def project_report
    authorize! :generate, :report # Check if the user can generate reports

    if params[:project_id].present? && params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day

      @project = Project.find(params[:project_id])

      if current_user.has_role?(:admin) || current_user.has_role?(:observer) || current_user.projects.include?(@project)
        @tickets = @project.tickets.joins(:statuses)
          .where.not(statuses: { name: %w[Resolved Closed Denied] })
          .where(created_at: start_date..end_date)

        @tickets_by_user = @tickets.group(:user_id).count

        respond_to do |format|
          format.html # Default view
          format.csv { send_data generate_project_report_csv(@tickets_by_user), filename: "project_report_#{Date.today}.csv" }
        end
      else
        flash[:alert] = 'You do not have access to this project.'
        redirect_to root_path
      end
    else
      @project = nil
      @tickets_by_user = {}
      flash[:alert] = 'Please provide a valid project and date range.'
      render :project_report
    end
  end

  def orm_report
    authorize! :generate, :report # Check if the user can generate reports

    @clients = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                 Client.all
               else
                 Client.joins(:projects).where(projects: { id: current_user.projects.ids }).distinct
               end

    if params[:days].present? || params[:client_id].present? || params[:status].present?
      days = params[:days].to_i
      outstanding_statuses = %w[Closed Resolved Declined]

      @tickets = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                   Ticket.joins(project: :client)
                     .joins(:statuses)
                     .where.not(statuses: { name: outstanding_statuses })
                 else
                   Ticket.joins(project: :client)
                     .joins(:statuses)
                     .where(projects: { id: current_user.projects.ids })
                     .where.not(statuses: { name: outstanding_statuses })
                 end

      if days.positive?
        closed_resolved_tickets = Ticket.joins(project: :client)
          .joins(:statuses)
          .where(statuses: { name: %w[Closed Resolved Declined] })
          .where('tickets.created_at >= ?', days.days.ago)
        @tickets = @tickets.or(closed_resolved_tickets)
      end

      @tickets = @tickets.where(projects: { client_id: params[:client_id] }) if params[:client_id].present?
      @tickets = @tickets.joins(:statuses).where(statuses: { name: params[:status] }) if params[:status].present?
      @status_counts = @tickets.joins(:statuses).group('statuses.name').count
      @ticket_counts = @tickets.group(:project_id).count
      @project_status_counts = @tickets.joins(:statuses).group(:project_id, 'statuses.name').count
    else
      @tickets = []
    end

    respond_to do |format|
      format.html # Default view
      if params[:client_id].present?
        client_name = Client.find(params[:client_id]).name
        filename = "orm_report_#{client_name}_#{Date.today}.csv"
        format.csv { send_data generate_orm_report_csv(@tickets, @ticket_counts, @project_status_counts), filename: filename }
      end
    end
  end

  def sod_report
    authorize! :generate, :report # Check if the user can generate reports

    # Find the team based on the provided team name
    team = Team.find_by(name: params[:team_name])

    if team

      user_ids = team.users.pluck(:id)
      outstanding_statuses = %w[Closed Resolved Declined]

      @tickets = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                   Ticket.joins(:users, project: :client)
                     .joins(:statuses)
                     .where(users: { id: user_ids })
                     .where.not(statuses: { name: outstanding_statuses })
                 else
                   Ticket.joins(:users, project: :client)
                     .joins(:statuses)
                     .where(users: { id: user_ids })
                     .where(projects: { id: current_user.projects.ids })
                     .where.not(statuses: { name: outstanding_statuses })
                 end
    else
      @tickets = [] # Initialize @tickets as an empty array if the team is not found
      flash[:alert] = 'Team not found.'
      redirect_to :sod_report and return
    end

    respond_to do |format|
      format.html # Default view
      format.csv { send_data generate_start_of_day_csv(@tickets), filename: "start_of_day_report_#{Date.today}.csv" }
    end
  end

  private

  def generate_orm_report_csv(tickets, ticket_counts, project_status_counts)
    CSV.generate(headers: true) do |csv|
      csv << ['Project Name', 'Total Number of Tickets', 'Status', 'Count']
      ticket_counts.each do |project_id, total_count|
        project = Project.find(project_id)
        csv << [project.title, total_count, '', '']
        project_status_counts.select { |k, _| k.first == project_id }.each do |(_proj_id, status), count|
          csv << ['', '', status, count]
        end
      end

      csv << []
      csv << ['Client Name', 'Ticket ID', 'Issue Type', 'Assignee', 'Reporter', 'Severity', 'Status', 'Created At', 'Updated At', 'Summary',
              'Content']
      tickets.each do |ticket|
        csv << [
          ticket.project.client.name,
          ticket.unique_id,
          ticket.issue,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.priority,
          ticket.statuses.first&.name || 'N/A',
          ticket.created_at.strftime('%d-%b-%Y'),
          ticket.updated_at.strftime('%d-%b-%Y'),
          ticket.subject,
          ticket.content.to_plain_text.truncate(3000)

        ]
      end
    end
  end

  def generate_project_report_csv(tickets_by_user)
    CSV.generate(headers: true) do |csv|
      csv << ['User Name', 'Ticket Count']
      tickets_by_user.each do |user_id, ticket_count|
        user = User.find(user_id)
        csv << [user.name, ticket_count]
      end
    end
  end

  def generate_csv(tickets)
    CSV.generate(headers: true) do |csv|
      csv << ['Summary', 'Issue Key', 'Issue Type', 'Status', 'Project Name', 'Priority', 'Assignee', 'Reporter', 'Created', 'Details']
      tickets.each do |ticket|
        csv << [
          ticket.subject,
          ticket.unique_id,
          ticket.issue,
          ticket.statuses.first&.name || 'N/A',
          ticket.project.title,
          ticket.priority,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.created_at,
          ticket.content.to_plain_text.truncate(800)
        ]
      end
    end
  end

  def generate_breach_details_csv(tickets)
    CSV.generate(headers: true) do |csv|
      csv << ['Summary', 'Issue Key', 'Issue Type', 'Status', 'Project Name', 'Priority', 'Assignee', 'Reporter', 'Created', 'SLA Status',
              'Target Response Deadline', 'Resolution Deadline']
      tickets.each do |ticket|
        sla_ticket = SlaTicket.find_by(ticket_id: ticket.id)
        csv << [
          ticket.subject,
          ticket.unique_id,
          ticket.issue,
          ticket.statuses.first&.name || 'N/A',
          ticket.project.title,
          ticket.priority,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.created_at,
          sla_ticket&.sla_status || 'N/A',
          sla_ticket&.sla_target_response_deadline.presence || 'not breached',
          sla_ticket&.sla_resolution_deadline.presence || 'not breached'
        ]
      end
    end
  end

  # Generate user report in CSV format
  def generate_user_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << ['User Name', 'Project Name', 'Ticket Subject', 'Ticket Status', 'SLA Status', 'SLA Target Response Deadline',
              'SLA Resolution Deadline', 'Created At']
      users.each do |user|
        user.tickets.each do |ticket|
          sla_ticket = SlaTicket.find_by(ticket_id: ticket.id)
          csv << [
            user.name,
            ticket.project.title,
            ticket.unique_id,
            ticket.subject,
            ticket.statuses.first&.name || 'N/A',
            sla_ticket&.sla_target_response_deadline || 'N/A',
            ticket.created_at('%d-%b-%Y'),
            ticket.updated_at.strftime('%d-%b-%Y')
          ]
        end
      end
    end
  end

  def generate_start_of_day_csv(tickets)
    CSV.generate(headers: true) do |csv|
      csv << ['Issue Key', 'Summary', 'Issue Type', 'Assignee', 'Reporter', 'Priority', 'Status', 'Resolution', 'Created', 'Updated', 'Due Date']
      tickets.each do |ticket|
        csv << [
          ticket.unique_id,
          ticket.subject,
          ticket.issue,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.priority,
          ticket.statuses.first&.name || 'N/A',
          ticket.created_at.strftime('%d-%b-%Y'),
          ticket.updated_at.strftime('%d-%b-%Y')
        ]
      end
    end
  end
end
