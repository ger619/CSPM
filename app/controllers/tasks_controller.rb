class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_board
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = @boards.tasks.all
  end

  def new
    @tasks = @boards.tasks.new
  end

  def create
    @tasks = @boards.tasks.new(task_params)
    @tasks.user = current_user
    @tasks.product = @product

    respond_to do |format|
      if @tasks.save
        # current_user.add_role :creator, @tasks
        # format.html { redirect_to product_board_path(@product, @boards), notice: 'Task was successfully created.' }
        format.html do
          redirect_to product_board_tasks_path(@product, @boards), notice: 'Task was successfully created.'
        end

      else
        format.html { redirect_to new_product_board_task_path(@product, @boards), alert: 'Task was not created.' }
      end
    end
  end

  def show
    @tasks = @boards.tasks.find(params[:id])
  end

  def edit; end

  def update
    if @tasks.update(task_params)
      redirect_to product_board_path(@product, @boards)
    else
      render :edit
    end
  end

  def destroy
    @tasks.destroy
    redirect_to product_board_path(@product, @boards)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_board
    @boards = @product.boards.find(params[:board_id])
  end

  def set_task
    @tasks = @boards.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name, :topic, :description, :start_date, :end_date, :product_id, :board_id, :user_id)
  end
end
