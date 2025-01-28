class BugController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_board
  before_action :set_task
  # before_action :set_bug, only: %i[show edit update destroy]

  def index
    @bugs = @task.bugs
  end

  def show
    # Add any necessary code for the show action
  end

  def new
    @bug = @task.bugs.new
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_board
    @board = @product.boards.find(params[:board_id])
  end

  def set_task
    @task = @board.tasks.find(params[:task_id])
  end

  def set_bug
    @bug = @task.bugs.find(params[:id])
  end

  def bug_params
    params.require(:bug).permit(:status, :task_id, :user_id)
  end
end
