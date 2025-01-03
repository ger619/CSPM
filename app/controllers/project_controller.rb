class ProjectController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy assign_user unassign_user]
  before_action :authenticate_user!
  load_and_authorize_resource
  # GET /projects
  def index
    @project = if params[:query].present?
                 Project.where('title ILIKE ? OR description ILIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
               else
                 Project.all.with_rich_text_content.order('created_at DESC')
               end

    @project = @project.joins(:users).where(users: { id: current_user.id }) unless current_user.has_role?(:admin)

    @per_page = 1
    @page = (params[:page] || 1).to_i
    @total_pages = (@project.count / @per_page.to_f).ceil
    @project = @project.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # GET /projects/id
  def show
    if current_user.has_role?(:admin) or @project.users.include?(current_user)
      @ticket = if params[:query].present?
                  @project.tickets.left_joins(:rich_text_content, :statuses)
                    .where('action_text_rich_texts.body ILIKE ? OR issue ILIKE ? OR priority ILIKE ? OR statuses.name ILIKE ? OR unique_id ILIKE ?',
                           "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%")

                else
                  @project.tickets.with_rich_text_content.order('created_at DESC')
                end
      @per_page = 10
      @page = (params[:page] || 1).to_i
      @total_pages = (@ticket.count / @per_page.to_f).ceil
      @ticket = @ticket.offset((@page - 1) * @per_page).limit(@per_page)
      # To pick the number of tickets that have status closed
      @closed_tickets = @project.tickets.joins(:statuses).where(statuses: { name: 'Closed' }).count
      # To pick the number of tickets that have status resolved
      @resolved_tickets = @project.tickets.joins(:statuses).where(statuses: { name: 'Resolved' }).count
      # Show the number of tickets assigned to the curent user
      @created_tickets = @project.tickets.where(user_id: current_user.id).count
      # Show the number of tickets assigned to the curent user
      @assigned_tickets = @project.tickets.joins(:users).where(users: { id: current_user.id }).count
      # assigned tickets that are closed or resolved
      @closed_assigned_tickets = @project.tickets.joins(:users, :statuses)
        .where(users: { id: current_user.id })
        .where(statuses: { name: %w[Closed Resolved] })
        .count

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
    params.require(:project).permit(:title, :description, :start_date, :content, :client_id, :user_id, software_ids: [], groupware_ids: [])
  end
end
