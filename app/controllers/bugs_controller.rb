class BugsController < ApplicationController
  before_action :set_product
  before_action :set_bug, only: %i[show edit update destroy]

  def index; end

  def new
    @bug = @product.bugs.build

    # Fetch associated softwares for the project
    @softwares = @product.softwares

    # Fetch groupwares associated with the project and the selected software
    # If a software_id is already selected, filter groupwares accordingly
    @groupwares = if @bug.software_id.present?
                    @product.groupwares
                      .joins(:softwares)
                      .where(softwares: { id: @ticket.software_id })
                      .distinct
                  else
                    # If no software is selected, load all groupwares for the project
                    @product.groupwares
                      .distinct
                  end
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
    set_bug
    if @bug.users.include?(User.find(params[:user_id]))
      redirect_to product_bugs_path(@product), notice: 'User has already been assigned.'
    else
      @bug.user = current_user
      user = User.find(params[:user_id])
      @bug.users.clear
      @bug.users << user

      # Send email to the newly assigned user
      assigned_user = user # Assuming the first user is the assigned user
      UserMailer.assignment_email(user, @bug, current_user, assigned_user).deliver_later

      redirect_to product_bugs_path(@product, @bug), notice: 'User was successfully assigned.'
    end
  end

  def unassign_tag
    user = User.find(params[:user_id])
    @ticket.users.delete(user)
    log_event(@ticket, current_user, 'unassign', "#{user.name} was unassigned from the ticket.")
    redirect_to project_ticket_path(@project, @ticket), notice: 'Ticket was successfully unassigned.'
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_bug
    @bug = @product.bugs.find(params[:id])
  end

  def bug_params
    params.require(:bug).permit(:issue, :priority, :video, :content, :product_id, :software_id, :groupware_id)
  end
end
