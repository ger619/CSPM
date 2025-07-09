class BugsController < ApplicationController
  before_action :set_defect
  before_action :set_bug, only: %i[show edit update destroy]

  def index; end

  def new
    @defect = Defect.find(params[:defect_id])
    @product = @defect.product
    @bug = Bug.new
    @bug.software_id = @product.softwares.first&.id if @product.softwares.any?
    @bug.groupware_id = @product.groupwares.where(software_id: @bug.software_id).first&.id if @product.groupwares.any?
  end

  def create
    @bug = @defect.bugs.build(bug_params)
    @bug.user = current_user

    if @bug.save
      redirect_to defect_bug_path(@defect, @bug), notice: 'Bug was successfully created.'
    else
      render :new, alert: 'Bug was unsuccessfully created.'
    end
  end

  def show; end

  def edit
    @product = @defect.product
    @bug.software_id = @product.softwares.first&.id if @product.softwares.any?
    @bug.groupware_id = @product.groupwares.where(software_id: @bug.software_id).first&.id if @product.groupwares.any?
  end

  def update
    if @bug.update(bug_params)
      redirect_to defect_bug_path(@defect, @bug), notice: 'Bug was successfully updated.'
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
      redirect_to defect_bugs_path(@defect), notice: 'User has already been assigned.'
    else
      @bug.user = current_user
      user = User.find(params[:user_id])
      @bug.users.clear
      @bug.users << user

      # Send email to the newly assigned user
      assigned_user = user # Assuming the first user is the assigned user
      UserMailer.bug_mailer_email(user, @bug, current_user, assigned_user).deliver_later

      redirect_to defect_bug_path(@defect, @bug), notice: 'User was successfully assigned.'

    end
  end

  def bug_status
    @bug = Bug.find(params[:id])
    status = Status.find(params[:status_id])
    @bug.statuses.clear
    @bug.statuses << status
    redirect_to defect_bug_path(@defect, @bug), notice: 'User was successfully assigned.'
  end

  def unassign_tag
    user = User.find(params[:user_id])
    @ticket.users.delete(user)
    log_event(@ticket, current_user, 'unassign', "#{user.name} was unassigned from the ticket.")
    redirect_to project_ticket_path(@defect, @ticket), notice: 'Ticket was successfully unassigned.'
  end

  private

  def set_defect
    @defect = Defect.find(params[:defect_id])
  end

  def set_bug
    @bug = @defect.bugs.find(params[:id])
  end

  def bug_params
    params.require(:bug).permit(:issue, :priority, :content, :defect_id, :software_id, :groupware_id, :label, :summary, videos: [], images: [])
  end
end
