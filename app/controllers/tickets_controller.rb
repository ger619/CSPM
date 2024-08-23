class TicketsController < ApplicationController
  before_action :authenticate_user! # This line ensures that the user is authenticated before any action is taken
  before_action :set_project, only: %i[show destroy edit update]
  before_action :set_ticket, only: %i[show destroy edit update]

  def index; end

  def show
    # Issues search this code is used to search for issues in the ticket
    @issue = if params[:query].present?
               @ticket.issues.left_joins(:rich_text_content).where('action_text_rich.content LIKE ?',
                                                                   "%#{params[:query]}%")
             else
               @ticket.issues.with_rich_text_content.order('created_at DESC')
             end
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@issue.count / @per_page.to_f).ceil
    @issue = @issue.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def new
    @ticket = @project.tickets.new
  end

  def create
    @tickets = @project.tickets.new(ticket_params)
    @tickets.user = current_user

    respond_to do |format|
      if @tickets.save
        current_user.add_role :creator, @tickets
        format.html { redirect_to project_path(@project), notice: 'ticket was successfully created.' }
      else
        # redirect_to new_project_path(@project), alert: 'ticket was not created.'
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ticket = @project.tickets.find(params[:id])
    @ticket.destroy
    redirect_to project_path(@project)
  end

  def edit; end

  def update
    @ticket = @project.tickets.find(params[:id])
    @ticket.user = current_user # Optional: If you want to ensure the user is always the current user

    respond_to do |format|
      if @ticket.update(ticket_params)
        current_user.add_role :editor, @ticket
        format.html { redirect_to project_path(@project.id), notice: 'Ticket was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Ticket was not updated.' }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:issue, :priority, :start_date, :body, :project_id, :user_id, :ticket_image)
  end
end
