class ProjectController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :authenticate_user!

  # GET /projects
  def index
    # @pagy,  @project = pagy(Project.all.with_rich_text_content.order('created_at DESC'), items: 5)
    @pagy, @project = if params[:query].present?
                        pagy_countless(Project.where('title LIKE ? OR description LIKE ?', "%#{params[:query]}%",
                                                     "%#{params[:query]}%"))
                      else
                        pagy_countless(Project.all.with_rich_text_content.order('created_at DESC'), items: 10)
                      end
    # @project = if params[:query].present?
    #            Project.where('title LIKE ? OR description LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
    #           else
    #             Project.all.with_rich_text_content.order('created_at DESC')
    #           end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /projects/id
  def show
    # @project = Project.find(params[:id])
    # @ticket = @project.tickets.all.order('created_at DESC')

    @ticket = if params[:query].present?
                @project.tickets.where('issues LIKE ? OR body LIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
              else
                @project.tickets.order('created_at DESC')
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
      if @project.save
        format.html { redirect_to project_url(@project), notice: 'Project was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/id
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to project_index_path, notice: 'Project was successfully updated.' }
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
    @project = Project.friendly.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.require(:project).permit(:title, :description, :start_date, :end_date, :content, :user_id)
  end
end
