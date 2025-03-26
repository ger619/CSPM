require 'csv'
require 'axlsx'

class DataCenterController < ApplicationController
  before_action :authenticate_user!
  def cease_fire_report
    authorize! :generate, :report # Check if the user can generate reports
    if params[:client_id].present? || params[:start_date].present? || params[:end_date].present? || params[:status].present?

      @tickets = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                   Ticket.joins(project: :client)
                 else
                   Ticket.joins(project: :client).where(projects: { id: current_user.projects.ids })
                 end

      @tickets = @tickets.where(projects: { client_id: params[:client_ids] }) if params[:client_ids].present?
      @tickets = @tickets.where(priority: params[:priority]) if params[:priority].present?

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
        filename = "ticket_status_report_#{client_name}_#{Date.today}.xlsx"
        format.xlsx { send_data generate_xlsx(@tickets), filename: filename }
      end
    else
      @tickets = Ticket.none
      flash[:alert] = 'Please provide a valid client.'
      render :cease_fire_report
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
    if params[:user_id].present? || params[:start_date].present? || params[:end_date].present?
      @users = User.includes(tickets: { project: :client })
        .where(id: params[:user_id])

      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

      @status_counts = @users.flat_map(&:tickets)
        .select { |ticket| (start_date.nil? || ticket.created_at >= start_date) && (end_date.nil? || ticket.created_at <= end_date) }
        .group_by { |ticket| ticket.statuses.first&.name || 'N/A' }
        .transform_values(&:count)

      @tickets_by_client = @users.flat_map(&:tickets)
        .select { |ticket| (start_date.nil? || ticket.created_at >= start_date) && (end_date.nil? || ticket.created_at <= end_date) }
        .group_by { |ticket| ticket.project.client.name }

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

  def user_report_view
    if params[:user_id] && params[:client_name]
      @user = User.find(params[:user_id])
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : nil
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : nil

      @tickets = @user.tickets.joins(project: :client)
        .where(clients: { name: params[:client_name] })
      @tickets = @tickets.where('tickets.created_at >= ?', start_date) if start_date
      @tickets = @tickets.where('tickets.created_at <= ?', end_date) if end_date
    else
      @tickets = Ticket.none
      flash[:alert] = 'Please provide a valid user and client.'
      render :user_report_view
    end
  end

  def project_report
    authorize! :generate, :report # Check if the user can generate reports

    if params[:team_id].present?
      @team = Team.find(params[:team_id])
      @team_members = @team.users
      user_ids = @team_members.pluck(:id)

      # Fetch tickets excluding specific statuses
      @tickets = Ticket.joins(:statuses, :project, :taggings)
        .where.not(statuses: { name: %w[Resolved Closed Declined] })
        .where(taggings: { user_id: user_ids })

      # Group tickets by user and status and show the counts of users and the tickets assigned
      @tickets_by_user = @tickets.joins(:statuses)
        .group('taggings.user_id', 'statuses.name')
        .count

      # Organize data into a hash for easier display in the view
      @organized_tickets = @tickets_by_user.each_with_object({}) do |((user_id, status), count), hash|
        hash[user_id] ||= { total: 0 }
        hash[user_id][:total] += count
        hash[user_id][status] = count
      end

      # Prepare data for the pie chart
      @tickets_chart_data = @organized_tickets.transform_keys { |id| User.find(id).name }
      @tickets_chart_data = @tickets_chart_data.transform_values { |data| data[:total] }
      @tickets_per_project = @tickets.group('projects.title').count

      respond_to do |format|
        format.html # Default view
        team_name = @team.name
        format.csv { send_data generate_project_report_csv(@tickets), filename: "#{team_name}_report_#{Date.today}.csv" }
      end
    else
      @team = nil
      @team_members = []
      @tickets_by_user = {}
      flash[:alert] = 'Please provide a valid team and date range.'
      render :project_report
    end
  end

  def assigned_tickets
    @team = Team.find(params[:team_id])
    if params[:user_id]
      @user = User.find(params[:user_id])
      @tickets = Ticket.joins(:statuses, :taggings, :project)
        .where.not(statuses: { name: %w[Resolved Closed Declined] })
        .where(taggings: { user_id: @user.id })
        .order('projects.title')
    else
      @tickets_by_user = Ticket.joins(:statuses, :taggings, :project)
        .where.not(statuses: { name: %w[Resolved Closed Declined] })
        .where(taggings: { user_id: @team.users.pluck(:id) })
        .order('projects.title')
        .group_by(&:user)
    end
  end

  def orm_report
    authorize! :generate, :report

    if params[:client_id].present? || params[:days].present?
      @clients = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                   Client.all
                 else
                   Client.joins(:projects).where(projects: { id: current_user.projects.ids }).distinct
                 end

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

      # Apply filtering if a specific client is selected
      @tickets = @tickets.where(projects: { client_id: params[:client_id] }) if params[:client_id].present?

      # Handle days filter
      if days.positive?
        closed_resolved_tickets = Ticket.joins(project: :client)
          .joins(:statuses)
          .where(statuses: { name: %w[Closed Resolved Declined] })
          .where('tickets.created_at >= ?', days.days.ago)
          .where(projects: { client_id: params[:client_id] })
        @tickets = @tickets.or(closed_resolved_tickets)
      end

      @tickets = @tickets.joins(:statuses).where(statuses: { name: params[:status] }) if params[:status].present?
      @status_counts = @tickets.joins(:statuses).group('statuses.name').count
      @ticket_counts = @tickets.group(:project_id).count
      @project_status_counts = @tickets.joins(:statuses).group(:project_id, 'statuses.name').count

      respond_to do |format|
        format.html
        format.csv do
          client_name = params[:client_id].present? ? Client.find(params[:client_id]).name : 'all_clients'
          filename = "orm_report_#{client_name}_#{Date.today}.csv"
          send_data generate_orm_report_csv(@tickets, @ticket_counts, @project_status_counts), filename: filename
        end
      end
    else
      @tickets = Ticket.none
      flash[:alert] = 'Please provide a valid client and days range.'
      render :orm_report
    end
  end

  def orm_team_report
    authorize! :generate, :report

    return unless params[:team_id].present? || params[:days].present?

    @teams = Team.all if current_user.has_any_role?(:admin, :observer, :project_manager)
    @teams ||= Team.none

    days = params[:days].to_i
    outstanding_statuses = %w[Closed Resolved Declined]

    if params[:team_id].present?
      team = Team.find_by(id: params[:team_id])
      if team.nil?
        @tickets = Ticket.none
        flash[:alert] = 'Please provide a valid team.'
        render :orm_report and return
      end

      # Get user IDs from the team
      user_ids = team.users.pluck(:id)

      # Retrieve tickets associated with the team's users via the taggings table
      @tickets = Ticket.joins(:taggings, :statuses)
        .joins('INNER JOIN add_statuses ON add_statuses.ticket_id = tickets.id') # Join add_statuses
        .where(taggings: { user_id: user_ids })
        .where(
          'statuses.name NOT IN (:outstanding_statuses) OR
                          (statuses.name IN (:outstanding_statuses) AND add_statuses.created_at >= :days_ago)',
          outstanding_statuses: outstanding_statuses,
          days_ago: days.days.ago
        )

      # Ensure non-admin users can only see their own project tickets
      @tickets = @tickets.joins(:project).where(projects: { id: current_user.projects.ids }) unless current_user.has_any_role?(:admin, :observer, :project_manager)

      # Filter by status if provided
      @tickets = @tickets.where(statuses: { name: params[:status] }) if params[:status].present?

      # Aggregate data
      @status_counts = @tickets.joins(:statuses).group('statuses.name').count
      @ticket_counts = @tickets.group(:project_id).count
      @project_status_counts = @tickets.joins(:statuses).group(:project_id, 'statuses.name').count

      respond_to do |format|
        format.html
        if params[:team_id].present?
          team_name = team.name
          filename = "orm_team_report_#{team_name}_#{Date.today}.csv"
          format.csv { send_data generate_orm_team_report_csv(@tickets, @ticket_counts, @project_status_counts), filename: filename }
        end
      end
    else
      @tickets = Ticket.none
      flash[:alert] = 'Please provide a valid team and days range.'
      render :orm_team_report
    end
  end

  def sod_report
    authorize! :generate, :report # Check if the user can generate reports

    # Find the team based on the provided team name
    team = Team.find_by(name: params[:team_name])

    if team
      user_ids = team.users.pluck(:id)
      outstanding_statuses = %w[Closed Resolved Declined]
      report_type = params[:report_type] # 'sod' for start of day, 'eod' for end of day

      base_scope = Ticket.joins(:users, project: :client)
        .joins(:statuses)
        .joins(:add_statuses)
        .where(users: { id: user_ids })

      # Apply role-based filtering if not admin or observer
      @tickets = if current_user.has_role?(:admin) || current_user.has_role?(:observer)
                   base_scope
                 else
                   base_scope.where(projects: { id: current_user.projects.ids })
                 end

      @tickets = if report_type == 'eod'
                   # EOD: Tickets that changed to "outstanding_statuses" within the last 24 hours
                   recently_updated_tickets = @tickets
                     .where(statuses: { name: outstanding_statuses })
                     .where('add_statuses.updated_at >= ?', 24.hours.ago)

                   # Get latest issues separately
                   Issue
                     .where(ticket_id: recently_updated_tickets.select(:id))
                     .order(updated_at: :desc)
                     .distinct(:ticket_id)

                   # Combine with tickets that are not in the outstanding statuses
                   @tickets.where.not(statuses: { name: outstanding_statuses }).or(recently_updated_tickets)
                 else
                   # SOD: Start of Day report shows tickets that are not in the outstanding statuses
                   @tickets.where.not(statuses: { name: outstanding_statuses })
                 end.order('add_statuses.updated_at DESC')
    else
      @tickets = [] # Initialize @tickets as an empty array if the team is not found
      flash[:alert] = 'Team not found.'
    end

    respond_to do |format|
      format.html # Default view
      format.csv do
        team_name = team&.name || 'unknown_team'
        filename = "#{report_type == 'sod' ? 'start_of_day' : 'end_of_day'}_report_#{team_name}_#{Date.today}.csv"
        send_data generate_start_of_day_csv(@tickets), filename: filename
      end
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
      csv << ['Client Name', 'Ticket ID', 'Issue Type', 'Assignee', 'Reporter', 'Severity', 'Status', 'Created At', 'Updated At',
              'Status Updated At', 'Last Comment Updated At', 'Summary', 'Resolution', 'Due Date']
      tickets.each do |ticket|
        csv << [
          ticket.project.client.name.gsub('–', '-'),
          ticket.unique_id.gsub('–', '-'),
          ticket.issue,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.priority,
          ticket.statuses.first&.name || 'N/A',
          ticket.created_at.strftime('%d-%b-%Y'),
          ticket.updated_at.strftime('%d-%b-%Y'),
          ticket.add_statuses.order(updated_at: :desc).first&.updated_at&.strftime('%d-%b-%Y %H:%M:%S') || 'N/A',
          ticket.issues.order(updated_at: :desc).first&.updated_at&.strftime('%H:%M of %d-%b-%Y') || 'N/A',
          ticket.subject,
          ticket.content.to_plain_text.truncate(3000),
          ticket.due_date&.strftime('%d-%b-%Y') || 'N/A'

        ]
      end
    end
  end

  def generate_orm_team_report_csv(tickets, ticket_counts, project_status_counts)
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
      csv << ['Client Name', 'Ticket ID', 'Issue Type', 'Assignee', 'Reporter', 'Severity', 'Status', 'Created At',
              'Status Updated At', 'Summary', 'Last Comment Updated At', 'Due Date']
      tickets.each do |ticket|
        csv << [
          ticket.project.client.name.gsub('–', '-'),
          ticket.unique_id.gsub('–', '-'),
          ticket.issue,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.priority,
          ticket.statuses.first&.name || 'N/A',
          ticket.created_at.strftime('%d-%b-%Y'),
          ticket.add_statuses.order(updated_at: :desc).first&.updated_at&.strftime('%d-%b-%Y %H:%M:%S') || 'N/A',
          ticket.subject,
          ticket.issues.order(updated_at: :desc).first&.updated_at&.strftime('%H:%M of %d-%b-%Y') || 'N/A',
          ticket.due_date&.strftime('%d-%b-%Y') || 'N/A'
        ]
      end
    end
  end

  def generate_project_report_csv(tickets)
    CSV.generate(headers: true) do |csv|
      csv << ['Project Name', 'Ticket ID', 'Issue Type', 'Assignee', 'Reporter', 'Severity', 'Status', 'Created At', 'Updated At', 'Summary', 'Content']
      tickets.each do |ticket|
        csv << [
          ticket.project.title,
          ticket.unique_id.gsub('–', '-'),
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

  def generate_xlsx(tickets)
    package = Axlsx::Package.new
    workbook = package.workbook

    # Define styles for each status
    styles = {
      'New' => workbook.styles.add_style(bg_color: 'EF4444'), # Red
      'Closed' => workbook.styles.add_style(bg_color: 'D9EAD3'), # Green
      'Resolved' => workbook.styles.add_style(bg_color: 'D9EAD3'), # Green
      'Reopened' => workbook.styles.add_style(bg_color: '87F1D1D'), # Dark Red with White text
      'Under Development' => workbook.styles.add_style(bg_color: '93C5FD'), # Light Blue
      'Work in Progress' => workbook.styles.add_style(bg_color: 'cccccc'), # Gray with White text
      'QA Testing' => workbook.styles.add_style(bg_color: 'EC4899'), # Pink
      'Awaiting Build' => workbook.styles.add_style(bg_color: '1F2937'), # Dark Slate Gray
      'Client Confirmation Pending' => workbook.styles.add_style(bg_color: 'FFF2CC'), # Purple with White text
      'On-Hold' => workbook.styles.add_style(bg_color: 'FF0000'), # Yellow
      'Assigned' => workbook.styles.add_style(bg_color: '1E40AF', fg_color: 'FFFFFF'), # Navy with White text
      'Declined' => workbook.styles.add_style(bg_color: '000000', fg_color: 'FFFFFF') # Dark Slate Gray with White text
    }

    # Group tickets by project
    tickets.group_by { |ticket| ticket.project.title }.each do |project_title, project_tickets|
      workbook.add_worksheet(name: project_title) do |sheet|
        sheet.add_row ['Ticket ID', 'Project Name', 'Severity', 'Summary', 'Issue Type', 'Status', 'Assignee To', 'Reporter', 'Details', 'Created', 'Status Updated At',
                       'Last Comment Updated At', 'Due Date']
        project_tickets.each do |ticket|
          status = ticket.statuses.first&.name || 'N/A'
          row_style = styles[status] || nil

          sheet.add_row [
            ticket.unique_id.gsub('–', '-'),
            ticket.project.title,
            ticket.priority,
            ticket.subject,
            ticket.issue,
            status,
            ticket.users.map(&:name).select(&:present?).join(', '),
            ticket.user.name,
            ticket.content.to_plain_text.truncate(3000),
            ticket.created_at.strftime('%d-%b-%Y'),
            ticket.add_statuses.order(updated_at: :desc).first&.updated_at&.strftime('%d-%b-%Y %H:%M:%S') || 'N/A',
            ticket.issues.order(updated_at: :desc).first&.updated_at&.strftime('%d-%b-%Y %H:%M:%S') || 'N/A',
            ticket.due_date&.strftime('%d-%b-%Y') || 'N/A'
          ], style: row_style
        end
      end
    end

    package.to_stream.read
  end

  def generate_breach_details_csv(tickets)
    CSV.generate(headers: true) do |csv|
      csv << ['Summary', 'Issue Key', 'Issue Type', 'Status', 'Project Name', 'Priority', 'Assignee', 'Reporter', 'Created', 'SLA Status',
              'Target Response Deadline', 'Resolution Deadline']
      tickets.each do |ticket|
        sla_ticket = SlaTicket.find_by(ticket_id: ticket.id)
        csv << [
          ticket.subject,
          ticket.unique_id.gsub('–', '-'),
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
              'SLA Repair Time Deadline', 'SLA Resolution Time Deadline', 'Created At']
      users.each do |user|
        user.tickets.each do |ticket|
          sla_ticket = SlaTicket.find_by(ticket_id: ticket.id)
          csv << [
            user.name,
            ticket.project.title,
            ticket.unique_id.gsub('–', '-'),
            ticket.subject,
            ticket.statuses.first&.name || 'N/A',
            sla_ticket&.sla_target_response_deadline || 'N/A',
            sla_ticket&.sla_resolution_deadline || 'N/A',
            ticket.created_at.strftime('%d-%b-%Y')
          ]
        end
      end
    end
  end

  def generate_start_of_day_csv(tickets)
    bom = "\uFEFF" # Add BOM to ensure UTF-8 compatibility in Excel

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ['Issue Key', 'Summary', 'Issue Type', 'Assignee', 'Reporter', 'Priority', 'Status', 'Created', 'Updated',
              'Status Updated At', 'Comment Added At', 'Content', 'Due Date']

      tickets.each do |ticket|
        latest_issue = Issue.where(ticket_id: ticket.id).order(updated_at: :desc).first
        csv << [
          ticket.unique_id.gsub('–', '-'),
          ticket.subject,
          ticket.issue,
          ticket.users.map(&:name).select(&:present?).join(', '),
          ticket.user.name,
          ticket.priority,
          ticket.statuses.first&.name || 'N/A',
          ticket.created_at.strftime('%d-%b-%Y'),
          ticket.add_statuses.order(updated_at: :desc).first&.updated_at&.strftime('%d-%b-%Y %H:%M:%S') || 'N/A',
          ticket.updated_at.strftime('%d-%b-%Y'),
          latest_issue&.created_at&.strftime('%d-%b-%Y %H:%M:%S') || 'N/A',
          latest_issue # rubocop:disable Style/SafeNavigationChainLength
            &.content&.to_plain_text&.truncate(800)
            &.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
            &.gsub("\u00A0", ' ') # Replace non-breaking spaces
            &.gsub(/[^\p{Print}]/, '') || 'N/A',
          ticket.due_date&.strftime('%d-%b-%Y') || 'N/A'
        ]
      end
    end

    bom + csv_data # Prepend BOM to the CSV output
  end
end
