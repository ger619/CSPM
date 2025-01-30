class BugsController < ApplicationController
  before_action :set_product
  before_action :set_board
  before_action :set_task

  def new
    @bug = @task.bugs.build
  end

  def create
    @bug = @task.bugs.build(bug_params)
    @bug.user = current_user

    if @bug.save
      redirect_to product_board_task_path(@product, @board, @task), notice: 'Bug was successfully created.'
    else
      render :new, alert: 'Bug was unsuccessfully created.'
    end
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

  def bug_params
    params.require(:bug).permit(:issue, :priority, :video,  :product_id, :board_id, :task_id)
  end
end
