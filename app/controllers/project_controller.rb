class ProjectController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy assign_user unassign_user]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /projects
  def index
    @projects = if params[:query].present?
                  search_projects(params[:query])
                else
                  Project.all.with_rich_text_content.order('projects.created_at ASC')
                end

    @projects = @projects.joins(:users).where(users: { id: current_user.id }) unless current_user.has_any_role?(:admin, :observer)

    @tickets = search_tickets(params[:query], @projects) if params[:query].present?

    paginate_projects
  end

  # GET /projects/:id
  def show
    if authorized_user?
      @tickets = filter_tickets(@project.tickets)
      @statuses = @project.tickets.joins(:statuses).distinct.pluck('statuses.name')
      paginate_tickets
      set_ticket_counts
    else
      redirect_to root_path, alert: 'You are not authorized to view this content.'
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/:id/edit
  def edit; end

  # POST /projects
  def create
    @project = Project.new(project_params)
    if authorized_to_create? && @project.save
      @project.users << @project.user if @project.users.empty?
      current_user.add_role :creator, @project
      redirect_to project_path(@project), notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:id
  def update
    if @project.update(project_params)
      current_user.add_role :editor, @project
      redirect_to project_path(@project), notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to edit_project_path(@project), alert: 'Duplicate groupware assignment detected. Please check your input.'
  end

  # DELETE /projects/:id
  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  def assign_user
    user = User.find(params[:user_id])
    if @project.users.include?(user)
      redirect_to @project, notice: 'User has already been assigned.'
    else
      @project.users << user
      UserMailer.assignment_email(user, @project, current_user, user).deliver_later
      redirect_to @project, notice: 'User was successfully assigned.'
    end
  end

  def add_team
    team = Team.find(params[:team_id])
    team.users.each do |user|
      next if @project.users.include?(user)

      @project.users << user
      UserMailer.assignment_email(user, @project, current_user, user).deliver_later
    end
    redirect_to @project, notice: 'Team and its users were successfully added to the project.'
  end

  def remove_team
    team = Team.find(params[:team_id])
    team.users.each { |user| @project.users.delete(user) }
    redirect_to @project, notice: 'Team and its users were successfully removed from the project.'
  end

  def unassign_user
    user = User.find(params[:user_id])
    @project.users.delete(user)
    redirect_to @project, notice: 'User was successfully unassigned.'
  end

  def groupwares
    software_id = params[:software_id]
    groupwares = @project.groupwares.joins(:softwares).where(softwares: { id: software_id }).distinct
    render json: groupwares
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :start_date, :content, :client_id, :user_id, :image, :special, software_ids: [], groupware_ids: [])
  end

  def search_projects(query)
    formatted_query = query.strip.count('-') == 2 ? query.strip.sub('-', '–') : query.strip
    Project.joins(:tickets)
      .where('projects.title ILIKE :query OR projects.description ILIKE :query OR tickets.unique_id ILIKE :query OR tickets.subject ILIKE :query', query: "%#{formatted_query}%")
      .distinct
  end

  def search_tickets(query, projects)
    formatted_query = query.strip.count('-') == 2 ? query.strip.sub('-', '–') : query.strip
    if current_user.has_any_role?(:admin, :observer) || projects.any? { |project| project.users.include?(current_user) }
      Ticket.joins(:project)
        .where('unique_id ILIKE :query OR subject ILIKE :query', query: "%#{formatted_query}%")
        .where(projects: { id: projects.ids })
    else
      Ticket.none
    end
  end

  def paginate_projects
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@projects.count / @per_page.to_f).ceil
    @projects = @projects.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def filter_tickets(tickets)
    tickets = tickets.left_joins(:rich_text_content, :statuses, :users)
    tickets = tickets.where('tickets.created_at::date BETWEEN ? AND ?', params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
    tickets = tickets.where('tickets.created_at::date >= ?', params[:start_date]) if params[:start_date].present?
    tickets = tickets.where('tickets.created_at::date <= ?', params[:end_date]) if params[:end_date].present?
    tickets = tickets.joins(:statuses).where(statuses: { name: params[:status] }) if params[:status].present?
    tickets = tickets.where(priority: params[:priority]) if params[:priority].present?
    tickets = tickets.where(issue: params[:issue]) if params[:issue].present?
    tickets = tickets.where(users: { id: params[:user_id] }) if params[:user_id].present?
    tickets = tickets.joins(:add_statuses).order("add_statuses.updated_at #{params[:order] == 'asc' ? 'ASC' : 'DESC'}") if params[:order].present?
    if params[:query].present?
      query = "%#{params[:query]}%"
      tickets = tickets.where(
        'action_text_rich_texts.body ILIKE ? OR issue ILIKE ? OR priority ILIKE ? OR statuses.name ILIKE ? OR unique_id ILIKE ?
          OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR tickets.created_at::text ILIKE ?',
        query, query, query, query, query, query, query, query
      )
    end
    tickets = tickets.joins(:users).where(users: { id: current_user.id }) if params[:filter] == 'Assigned'
    tickets = tickets.joins(:users).where.not(statuses: { name: %w[Closed Resolved Declined] }) if params[:filter] == 'Open'
    tickets
  end

  def paginate_tickets
    @per_page = 10
    @page = params[:page].to_i.positive? ? params[:page].to_i : 1
    @total_pages = (@tickets.count / @per_page.to_f).ceil
    @tickets = @tickets.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def set_ticket_counts
    @created_tickets = @project.tickets.where(user_id: current_user.id).count
    @assigned_tickets_count = @project.tickets.joins(:users).where(users: { id: current_user.id }).count
    @closed_assigned_tickets = @project.tickets.joins(:users, :statuses).where(users: { id: current_user.id }).where(statuses: { name: %w[Closed Resolved] }).count
    @breached_target_tickets_count = @project.tickets.count_target_breached_sla
  end

  def authorized_user?
    current_user.has_role?(:admin) || @project.users.include?(current_user) || current_user.has_role?(:observer) || current_user.has_role?(:agent)
  end

  def authorized_to_create?
    current_user.has_role?(:admin) || current_user.has_role?('project_manager')
  end
end
