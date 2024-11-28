# app/controllers/invitations_controller.rb
class InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!
  # before_action :set_user, only: %i[new create]

  def new
    @user = User.new
    self.resource = @user
  end

  def create
    if invite_params[:email].blank?
      flash.now[:alert] = 'Email cannot be blank.'
      render :new
      return
    end
    invited_user = User.find_by(email: invite_params[:email], first_name: invite_params[:first_name], last_name: invite_params[:last_name])

    if invited_user
      invited_user.invite!(current_user)
      notice_message = 'Invitation resent successfully.'
    else
      invited_user = User.invite!(invite_params, current_user)
      notice_message = 'User has been invited successfully.' if invited_user.errors.blank?
    end

    if invited_user.errors.blank?
      invited_user.add_role(params[:role]) if params[:role].present?
      redirect_to users_path, notice: notice_message
    else
      flash.now[:alert] = 'There was an error inviting the user.'
      render :new
    end
  end

  private

  def invite_params
    params.require(:user).permit(:email, :first_name, :last_name, roles: [])
  end

  def assign_role(invited_user)
    return unless params[:role].present?

    if current_user.has_role?(:admin)
      invited_user.add_role(params[:role])
    elsif current_user.has_role?(:project_manager)
      invited_user.add_role(params[:role]) unless params[:role] == 'admin'
    else
      invited_user.add_role(params[:role]) unless params[:role] == 'admin' || params[:role] == 'project_manager'
    end
  end
end
