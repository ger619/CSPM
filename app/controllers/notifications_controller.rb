class NotificationsController < ApplicationController
  before_action :authenticate_user!
  include ActionView::Helpers::DateHelper

  def index
    @notifications = current_user.notifications.order(created_at: :desc) || []

    # Render notifications as JSON
    render json: {
      notifications: @notifications.map { |n|
        {
          message: n.message,
          user_initials: current_user.name_initials,
          time_ago: time_ago_in_words(n.created_at),
          read: n.read
        }
      },
      unread_count: @notifications.where(read: false).count
    }
  end

  def load_notifications
    @notifications = current_user.notifications.order(created_at: :desc)

    notifications_data = @notifications.map do |notification|
      {
        user_initials: notification.user.name_initials,
        message: notification.message,
        time_ago: time_ago_in_words(notification.created_at),
        read: notification.read
      }
    end

    unread_count = @notifications.where(read: false).count

    render json: {
      notifications: notifications_data,
      unread_count: unread_count
    }
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
