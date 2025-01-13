class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task

  def new
    @task = Task.find(params[:task_id])
    @message = @task.messages.build
  end

  def show
    @task = Task.find(params[:id])
    @message = @task.messages.build
  end

  def index
    Rails.logger.debug "Task: #{@task.inspect}"
    Rails.logger.debug "Messages: #{@messages.inspect}"

    @messages = @task.messages.select { |message| message.visible_to?(current_user) }
  end

  def create
    @message = @task.messages.build(message_params)
    @message.user = current_user
    if @message.save
      current_user.add_role :creator, @message
      render :index, notice: 'Message was successfully assigned.'
    else
      flash.now[:alert] = 'Failed to create the message.'
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def message_params
    params.require(:message).permit(:message_type, :content, attachments: [])
  end
end
