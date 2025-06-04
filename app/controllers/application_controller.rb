class ApplicationController < ActionController::Base
  include Pagy::Backend
  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: %i[new create]
  before_action :update_allowed_parameters, if: :devise_controller?
  before_action :check_user_state
  before_action :load_notifications, if: :user_signed_in?

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_root
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  def update_allowed_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:email, :password) }
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:name, :email, :password, :current_password, :profile_picture, :first_name, :last_name, :first_login)
    end
    devise_parameter_sanitizer.permit(:invite, keys: %i[email role])
  end

  private

  def check_user_state
    return unless user_signed_in?

    unless current_user.active
      sign_out current_user
      redirect_to new_user_session_path, alert: 'Your account is deactivated. Please contact the administrator.' and return
    end

    if !current_user.first_login && controller_name != 'registrations' && action_name != 'edit'
      redirect_to edit_user_registration_path, alert: 'Please complete your profile before continuing.' and return
    end

    return unless controller_name == 'registrations' && action_name == 'update' && params[:user].present?
    return unless current_user.update(first_login: true, first_name: params[:user][:first_name], last_name: params[:user][:last_name])

    if user_signed_in? && current_user.has_role?(:ceo) && !request.path.start_with?(cease_fire_report_path)
      redirect_to cease_fire_report_path
    else
      redirect_to root_path, alert: 'Profile is Updated.' and return
    end
  end

  def load_notifications
    return unless user_signed_in?

    @notifications = current_user.notifications.order(created_at: :desc)
  end

  # def redirect_based_on_role
  #  return unless user_signed_in? && current_user.has_role?(:ceo) && !request.path.start_with?(cease_fire_report_path)

  #  redirect_to cease_fire_report_path
  # end

  def redirect_to_root
    redirect_to root_path, alert: 'The page you were looking for does not exist.'
  end
end
