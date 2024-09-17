class ApplicationController < ActionController::Base
  include Pagy::Backend
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :update_allowed_parameters, if: :devise_controller?
  before_action :check_profile_completion

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_root

  def update_allowed_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:email, :password) }
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:name, :email, :password, :current_password, :profile_picture, :first_name, :last_name, :first_login)
    end
    devise_parameter_sanitizer.permit(:invite, keys: %i[email role])
  end

  private

  def check_profile_completion
    if user_signed_in? && !current_user.first_login && controller_name != 'registrations' && action_name != 'edit'
      redirect_to edit_user_registration_path, alert: 'Please complete your profile before continuing.'
    end
    return unless user_signed_in? && controller_name == 'registrations' && action_name == 'update'

    current_user.update(first_login: true, first_name: params[:user][:first_name],
                        last_name: params[:user][:last_name])
    redirect_to root_path, alert: 'Profile is Updated.'
  end

  def redirect_to_root
    redirect_to root_path, alert: 'The page you were looking for does not exist.'
  end
end
