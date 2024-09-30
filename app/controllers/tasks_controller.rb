class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_board
  before_action :set_task, only: %i[show edit update destroy add_task remove_task]

  def index
    @tasks = @board.tasks
  end

  def new
    @task = @board.tasks.new
  end

  def create
    @task = @board.tasks.new(task_params)
    @task.product_id = params[:product_id]
    @task.user = current_user

    respond_to do |format|
      if @task.save
        # current_user.add_role :creator, @task
        Rails.logger.info('Task was successfully created.')
        current_user.add_role :creator, @task
        format.html { redirect_to product_path(@product), notice: 'Task was successfully created.' }
      else
        Rails.logger.debug 'Task save failed: #{@task.errors.full_messages.join(', ')}'
        format.html { render :new, alert: 'Task was not created.' }
      end
    end
  end

  def show
    @task = @board.tasks.find(params[:id])
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to product_board_path(@product, @board)
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to product_board_path(@product, @board)
  end

  # Assigning User a Task

  def add_task; end

  def remove_task; end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_board
    @board = @product.boards.find(params[:board_id])
  end

  def set_task
    @task = @board.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :topic, :description, :start_date, :end_date, :image, :board_id,
                                 :user_id)
  end
end
