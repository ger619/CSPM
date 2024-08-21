class ProjectController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :authenticate_user!
  load_and_authorize_resource
  # GET /projects
  def index
    @pagy, @project = if params[:query].present?
                        pagy_countless(Project.where('title LIKE ? OR description LIKE ?', "%#{params[:query]}%",
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
    @pagy, @ticket = if params[:query].present?
                       pagy_countless(
                         @project.tickets.left_joins(:rich_text_body).where('action_text_rich_texts.body LIKE ?',
                                                                            "%#{params[:query]}%"), items: 10
                       )
                     else
                       pagy_countless(@project.tickets.with_rich_text_body.order('created_at DESC'), items: 10)
                     end
    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
