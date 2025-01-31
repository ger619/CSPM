class BugsController < ApplicationController
  before_action :set_product
  # before_action :set_board
  # before_action :set_task
  before_action :set_bug, only: %i[show edit update destroy]

  def index
    @bugs = Bug.joins(task: :board).where(boards: { product_id: @product.id })
  end

  def new
    @bug = @product.bugs.build
  end

  def create
    @bug = @product.bugs.build(bug_params)
    @bug.user = current_user

    if @bug.save
      redirect_to product_path(@product), notice: 'Bug was successfully created.'
    else
      render :new, alert: 'Bug was unsuccessfully created.'
    end
  end

  def show; end

  def edit; end

  def update
    if @bug.update(bug_params)
      redirect_to product_path(@product), notice: 'Bug was successfully updated.'
    else
      render :edit, alert: 'Bug was unsuccessfully updated.'
    end
  end

  def destroy
    @bug.destroy
    redirect_to product_path(@product), notice: 'Bug was successfully deleted.'
  end

  def add_bug
    @task = Task.find(params[:task_id])
    @bug = @task.bugs.find(params[:id])
    user = User.find(params[:user_id])

    if @bug.users.include?(user)
      redirect_to product_path(@product), notice: 'User has already been assigned.'
    else
      @bug.user = current_user
      @bug.users.clear
      @bug.users << user

      # Send email to the newly assigned user
      assigned_user = user # Assuming the first user is the assigned user
      UserMailer.assignment_email(user, @bug, current_user, assigned_user).deliver_later

      redirect_to product_bugs_path(@product, @bug), notice: 'User was successfully assigned.'
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_bug
    @bug = @product.bugs.find(params[:id])
  end

  def bug_params
    params.require(:bug).permit(:issue, :priority, :video, :content, :product_id)
  end
end
