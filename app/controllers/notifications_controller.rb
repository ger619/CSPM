class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc) || []
  end

  def mark_as_read
    @notification = current_user.notifications.find(params[:id])
    if @notification.update(read: true)
      redirect_to notifications_path, notice: 'Notification marked as read.'
    else
      redirect_to notifications_path, alert: 'Failed to mark notification as read.'
    end
  end
end
