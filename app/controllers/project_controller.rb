class ProjectController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy assign_user unassign_user]
  before_action :authenticate_user!
  load_and_authorize_resource
  # GET /projects
  def index
    if params[:query].present?
      query_str = params[:query].strip

      # Replace only the first hyphen with an en dash if there are exactly two hyphens
      formatted_query = query_str.count('-') == 2 ? query_str.sub('-', '–') : query_str

      @project = Project.joins(:tickets)
        .where('projects.title ILIKE :query
              OR projects.description ILIKE :query
              OR tickets.unique_id ILIKE :query
              OR tickets.subject ILIKE :query',
               query: "%#{formatted_query}%")
        .distinct
    else
      @project = Project.all.with_rich_text_content.order('projects.title ASC')
    end

    @project = @project.joins(:users).where(users: { id: current_user.id }) unless current_user.has_any_role?(:admin, :observer)

    @tickets = if params[:query].present?
                 if current_user.has_any_role?(:admin, :observer) || @project.any? { |project| project.users.include?(current_user) }
                   Ticket.joins(:project)
                     .where('unique_id ILIKE :query OR subject ILIKE :query', query: "%#{formatted_query}%")
                     .where(projects: { id: @project.ids })
                 else
                   Ticket.none
                 end
               else
                 Ticket.none
               end

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@project.count / @per_page.to_f).ceil
    @project = @project.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # GET /projects/id
  def show
    if current_user.has_role?(:admin) || @project.users.include?(current_user) || current_user.has_role?(:observer) || current_user.has_role?(:agent)
      @ticket = @project.tickets.left_joins(:rich_text_content, :statuses, :users)

      # ✅ Apply filters while persisting selection
      if params[:start_date].present? && params[:end_date].present?
        @ticket = @ticket.where('tickets.created_at::date BETWEEN ? AND ?', params[:start_date], params[:end_date])
      elsif params[:start_date].present?
        @ticket = @ticket.where('tickets.created_at::date >= ?', params[:start_date])
      elsif params[:end_date].present?
        @ticket = @ticket.where('tickets.created_at::date <= ?', params[:end_date])
      end

      @ticket = @ticket.joins(:statuses).where(statuses: { name: params[:status] }) if params[:status].present?
      @ticket = @ticket.where(priority: params[:priority]) if params[:priority].present?
      @ticket = @ticket.where(issue: params[:issue]) if params[:issue].present?
      @ticket = @ticket.where(users: { id: params[:user_id] }) if params[:user_id].present?
      order_direction = params[:order] == 'asc' ? 'ASC' : 'DESC'
      @ticket = @ticket.joins(:add_statuses).order("add_statuses.updated_at #{order_direction}") if params[:order].present?
      if params[:query].present?
        query = "%#{params[:query]}%"
        @ticket = @ticket.where(
          'action_text_rich_texts.body ILIKE ? OR issue ILIKE ? OR priority ILIKE ? OR statuses.name ILIKE ? OR unique_id ILIKE ?
      OR users.first_name ILIKE ? OR users.last_name ILIKE ? OR tickets.created_at::text ILIKE ?',
          query, query, query, query, query, query, query, query
        )
      end

      @statuses = @project.tickets.joins(:statuses).distinct.pluck('statuses.name')

      @ticket = @ticket.joins(:users).where(users: { id: current_user.id }) if params[:filter] == 'Assigned'
      @ticket = @ticket.joins(:users).where.not(statuses: { name: %w[Closed Resolved Declined] }) if params[:filter] == 'Open'

      @tickets = if params[:filter] == 'closed_assigned'
                   @project.tickets.joins(:users, :statuses)
                     .where(users: { id: current_user.id })
                     .where(statuses: { name: %w[Closed Resolved] })
                 else
                   @project.tickets.joins(:users, :statuses)
                     .where(users: { id: current_user.id })
                     .where.not(statuses: { name: %w[Closed Resolved] })
                 end

      # ✅ Order by descending creation date
      @ticket = @ticket.order(created_at: :desc)

      # Store the count of the filtered tickets
      @ticket_count = @ticket.count

      # ✅ Pagination (Fix offset calculation)
      @per_page = 10
      @page = params[:page].to_i.positive? ? params[:page].to_i : 1
      @total_pages = (@ticket.count / @per_page.to_f).ceil
      @ticket = @ticket.offset((@page - 1) * @per_page).limit(@per_page)

      # ✅ Ticket counts
      @created_tickets = @project.tickets.where(user_id: current_user.id).count
      @assigned_tickets_count = @project.tickets.joins(:users).where(users: { id: current_user.id }).count

      @closed_assigned_tickets = @project.tickets.joins(:users, :statuses)
        .where(users: { id: current_user.id })
        .where(statuses: { name: %w[Closed Resolved] })
        .count
      @breached_target_tickets_count = @project.tickets.count_target_breached_sla
    else
      redirect_to root_path, alert: 'You are not authorized to view this content.'
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/id/edit
  def edit; end

  # POST /projects
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      # Check if the user has the appropriate role
      if current_user.has_role?(:admin) || current_user.has_role?('project_manager')
        # Validate the presence of content
        if @project.content.blank?
          @project.errors.add(:content, 'Subject cannot be blank.') # Add validation error
          # Render the form with validation errors
          format.html { render :new, status: :unprocessable_entity }
        elsif @project.save
          @project.users << @project.user if @project.users.empty?
          current_user.add_role :creator, @project
          format.html { redirect_to project_path(@project), notice: 'Project was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        # Render an unauthorized error
        format.html do
          render :new, status: :unprocessable_entity, notice: 'You are not authorized to create a project.'
        end
      end
    end
  end

  # PATCH/PUT /projects/id
  def update
    respond_to do |format|
      if @project.update(project_params)
        current_user.add_role :editor, @project
        format.html { redirect_to project_path(@project), notice: 'Project was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity }
      end
    rescue ActiveRecord::RecordNotUnique
      format.html { redirect_to edit_project_path(@project), alert: 'Duplicate groupware assignment detected. Please check your input.' }
    end
  end

  # DELETE /projects/id
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to project_url, notice: 'Project was successfully destroyed.' }
    end
  end

  def assign_user
    if @project.users.include?(User.find(params[:user_id]))
      redirect_to @project, notice: 'User has already been assigned.'
    else
      @project = Project.find(params[:id])
      user = User.find(params[:user_id])
      @project.user = current_user
      @project.users << user

      # Send email to the newly assigned user
      assigned_user = user # Assuming the first user is the assigned user
      UserMailer.assignment_email(user, @project, current_user, assigned_user).deliver_later
      # @project.users.each do |project_user|
      #  next if project_user == current_user

      #  UserMailer.assignment_email(project_user, @project, current_user, assigned_user).deliver_later
      #  end

      redirect_to @project, notice: 'User was successfully assigned.'
    end
  end

  def add_team
    @project = Project.find(params[:id])
    team = Team.find(params[:team_id])
    @project.user = current_user

    team.users.each do |user|
      unless @project.users.include?(user)
        @project.users << user
        UserMailer.assignment_email(user, @project, current_user, user).deliver_later
      end
    end

    redirect_to @project, notice: 'Team and its users were successfully added to the project.'
  end

  def remove_team
    @project = Project.find(params[:id])
    team = Team.find(params[:team_id])

    team.users.each do |user|
      @project.users.delete(user)
    end

    redirect_to @project, notice: 'Team and its users were successfully removed from the project.'
  end

  def unassign_user
    @project = Project.find(params[:id])
    user = User.find(params[:user_id])
    @project.users.delete(user)
    redirect_to @project, notice: 'User was successfully unassigned.'
  end

  def groupwares
    software_id = params[:software_id]
    # Fetch groupwares associated with the current project and the selected software_id
    groupwares = @project.groupwares
      .joins(:softwares)
      .where(softwares: { id: software_id })
      .distinct
    render json: groupwares
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.require(:project).permit(:title, :description, :start_date, :content, :client_id, :user_id, :image, :special,
                                    software_ids: [], groupware_ids: [])
  end
end
