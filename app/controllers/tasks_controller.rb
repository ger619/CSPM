class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_board
  before_action :set_task, only: %i[show edit update destroy add_task remove_task add_state]

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
        current_user.add_role :creator, @task
        format.html { redirect_to product_path(@product), notice: 'Task was successfully created.' }
      else
        format.html do
          redirect_to new_product_board_task_path(@product, @board, @task), notice: 'Task was not created.'
        end
      end
    end
  end

  def show
    @task = @board.tasks.find(params[:id])
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to product_path(@product), notice: 'Task was successfully created.'
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to product_path(@product), notice: 'Task was successfully deleted.'
  end

  # Assigning User a Task

  def add_task
    if @task.users.include?(User.find(params[:user_id]))
      redirect_to product_board_task_path(@product, @board, @task), notice: 'User has already been assigned.'
    else
      @task = @board.tasks.find(params[:id])
      @task.user = current_user
      user = User.find(params[:user_id])
      @task.users.clear
      @task.users << user
      assigned_user = user # Sending to all users added to the product
      # Send email to the newly assigned user
      UserMailer.task_assignment_email(user, @task, current_user, assigned_user).deliver_later
      # Send email to all users tagged on the product, except the current user
      # @product.users.each do |product_user|
      #   next if product_user == current_user

      #   UserMailer.task_assignment_email(product_user, @task, current_user, assigned_user).deliver_later
      # end

      redirect_to product_board_task_path(@product, @board, @task), notice: 'Task was successfully assigned.'
    end
  end

  def remove_task
    @task.users.delete(User.find(params[:user_id]))
    redirect_to product_board_task_path(@product, @board, @task), notice: 'Task was successfully unassigned.'
  end

  def add_state
    @task = @board.tasks.find(params[:id])

    if @task.board_id == params[:status].to_i
      redirect_to product_path(@product), alert: 'The task is already in the selected state.'
      return
    end

    @task.board_id = params[:status]
    @task.save

    UserMailer.add_state_email(@task.user, @task, current_user).deliver_later
    # @product.users.each do |product_user|
    #   next if product_user == current_user

    #   UserMailer.add_state_email(product_user, @task, current_user).deliver_later
    # end
    redirect_to product_path(@product)
  end

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
