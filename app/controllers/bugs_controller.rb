class BugsController < ApplicationController
  before_action :set_product
  before_action :set_board
  before_action :set_task
  before_action :set_bug, only: %i[show edit update destroy]

  def index
    @bugs = Bug.joins(task: :board).where(boards: { product_id: @product.id })
  end

  def new
    @bug = @task.bugs.build
  end

  def create
    @bug = @task.bugs.build(bug_params)
    @bug.user = current_user
    @bug.product_id = @product.id
    @bug.board_id = @board.id

    if @bug.save
      redirect_to product_board_task_path(@product, @board, @task), notice: 'Bug was successfully created.'
    else
      render :new, alert: 'Bug was unsuccessfully created.'
    end
  end

  def show; end

  def edit; end

  def update
    if @bug.update(bug_params)
      redirect_to product_board_task_path(@product, @board, @task), notice: 'Bug was successfully updated.'
    else
      render :edit, alert: 'Bug was unsuccessfully updated.'
    end
  end

  def destroy
    @bug.destroy
    redirect_to product_board_task_path(@product, @board, @task), notice: 'Bug was successfully deleted.'
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
    params.require(:bug).permit(:issue, :priority, :video, :content, :product_id, :board_id, :task_id)
  end
end
