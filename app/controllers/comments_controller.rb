class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  before_action :set_comment, only: %i[destroy edit update]

  def create
    @comment = @ticket.comments.new(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to ticket_path(@ticket), notice: 'Comment was successfully created.' }
      else
        format.html { render 'tickets/show', status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment = @ticket.comments.find(params[:id])
    @comment.destroy
    redirect_to ticket_path(@ticket)
  end

  def edit; end

  def update
    @comment = @ticket.comments.find(params[:id])
    @comment.user = current_user

    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to ticket_path(@ticket), notice: 'Comment was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity }
      end
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def set_comment
    @comment = @ticket.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:ticket_id, :what, :why, :solution, :user_id)
  end
end
