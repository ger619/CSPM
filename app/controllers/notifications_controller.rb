class NotificationsController < ApplicationController
  before_action :authenticate_user!
  include ActionView::Helpers::DateHelper
  include Pagy::Backend

  def index
    @pagy, @notifications = pagy(
    current_user.notifications.order(created_at: :desc), 
      items: 10 
    )
    
    respond_to do |format|
      format.html 
      format.json do
        render json: {
          notifications: @notifications.map { |n| format_notification(n) },
          unread_count: @notifications.where(read: false).count
        }
      end
    end
  end  

  def show
    @pagy, @notifications = pagy(current_user.notifications.order(created_at: :desc))
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
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def mark_as_read
    @notification = Notification.find(params[:id])
    @notification.update(read: true)

    redirect_to notifications_path, notice: "Notification marked as read."
  end

  def mark_as_unread
    @notification = Notification.find(params[:id])
    @notification.update!(read: false)

    redirect_to notifications_path, notice: "Notification marked as unread."
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
