class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_board
  before_action :set_task, only: %i[show edit update destroy]


  def index
    @task = @board.tasks
  end

  def new
    @task = @board.tasks.new
  end

  def create
    @task = @board.tasks.new(task_params)
    @task.product = @product
    @task.user = current_user

    respond_to do |format|
      if @task.save
        current_user.add_role :creator, @task
        format.html { redirect_to product_board_path(@product, @board), notice: 'Task was successfully created.' }
      else
        format.html { redirect_to new_product_board_task_path(@product, @board), alert: 'Task was not created.' }
      end
    end
  end

  def show
    @task = @board.tasks.find(params[:id])
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to product_board_path(@product, @boards)
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to product_board_path(@product, @boards)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_board
    @board = @product.boards.find(params[:board_id])
  end

  def set_task
    @tasks = @board.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :topic, :description, :start_date, :end_date, :image, :product_id, :board_id,
                                 :user_id)
  end
end
