class NotificationsController < ApplicationController
  before_action :authenticate_user!
  include ActionView::Helpers::DateHelper

  def index
    @notifications = current_user.notifications.order(created_at: :desc)

    # Render notifications as JSON
    render json: {
      notifications: @notifications.map { |n| format_notification(n) },
      unread_count: @notifications.where(read: false).count
    }
  end

  def load_notifications
    @notifications = current_user.notifications.order(created_at: :desc)

    if @notifications.present?
      render json: {
        notifications: @notifications.map { |notification| format_notification(notification) },
        unread_count: @notifications.where(read: false).count
      }
    else
      render json: { notifications: [], unread_count: 0 }, status: :ok
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def mark_as_read
    notification = Notification.find(params[:id])
    notification.update(read: true)
    head :ok
  end

  def mark_as_unread
    notification = Notification.find(params[:id])
    notification.update(read: false)
    head :ok
  end

  private

  # Helper to format notification details
  def format_notification(notification)
    {
      id: notification.id,
      user_initials: notification.user.name_initials || notification.user.name[0..1].upcase,
      message: notification.message,
      time_ago: time_ago_in_words(notification.created_at),
      read: notification.read
    }
  end
end
