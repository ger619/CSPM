class ProjectController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy assign_user unassign_user]
  before_action :authenticate_user!
  load_and_authorize_resource
  # GET /projects
  def index
    @pagy, @project = if params[:query].present?
                        pagy_countless(Project.where('title ILIKE ? OR description ILIKE ?', "%#{params[:query]}%",
                                                     "%#{params[:query]}%"), items: 10)
                      else
                        pagy_countless(Project.all.with_rich_text_content.order('created_at DESC'), items: 10)
                      end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /projects/id
  def show
    @ticket = if params[:query].present?
                @project.tickets.left_joins(:rich_text_body).where('action_text_rich_texts.body ILIKE ?',
                                                                   "%#{params[:query]}%")
              else
                @project.tickets.with_rich_text_body.order('created_at DESC')
              end
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@ticket.count / @per_page.to_f).ceil
    @ticket = @ticket.offset((@page - 1) * @per_page).limit(@per_page)
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/id/edit
  def edit
    # @project = Project.find(params[:id])
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    @project.user_id = current_user.id

    respond_to do |format|
      if current_user.has_role?(:admin) || current_user.has_role?('project_manager')
        if @project.save
          current_user.add_role :creator, @project
          format.html { redirect_to project_path(@project), notice: 'Project was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      else
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
      UserMailer.assignment_email(user, @project, current_user).deliver_now

      # Send email to all users assigned to the project
      @project.users.each do |project_user|
        UserMailer.assignment_email(project_user, @project, current_user).deliver_now
      end

      redirect_to @project, notice: 'User was successfully assigned.'
    end
  end

  def unassign_user
    @project = Project.find(params[:id])
    user = User.find(params[:user_id])
    @project.users.delete(user)
    redirect_to @project, notice: 'User was successfully unassigned.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.require(:project).permit(:title, :description, :start_date, :end_date, :content, :user_id)
  end
end
