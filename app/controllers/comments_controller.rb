class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project
  before_action :set_ticket
  before_action :set_comment, only: %i[destroy edit update]

  def new
    @comment = @ticket.comments.new
  end

  def create
    @comment = @ticket.comments.new(comment_params)
    @comment.project = @project
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Comment was successfully created.' }
      else
        format.html { render 'new', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = @ticket.comments.find(params[:id])
    @comment.destroy
    redirect_to project_ticket_path(@project, @ticket)
  end

  def edit; end

  def update
    @comment = @ticket.comments.find(params[:id])
    @comment.project = @project
    @comment.user = current_user

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Comment was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:ticket_id])
  end

  def set_comment
    @comment = @ticket.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:ticket_id, :what, :why, :content, :user_id, :project_id)
  end
end
