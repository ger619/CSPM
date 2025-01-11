# app/controllers/invitations_controller.rb
class InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!
  # before_action :set_user, only: %i[new create]

  def new
    @user = User.new
    self.resource = @user
    @resource_name = :user
  end

  def create
    if invite_params[:email].blank?
      flash.now[:alert] = 'Email cannot be blank.'
      render :new
      return
    end

    invited_user = User.find_by(email: invite_params[:email], first_name: invite_params[:first_name], last_name: invite_params[:last_name],
                                client_id: invite_params[:client_id])

    if invited_user
      flash[:alert] = 'User already exists.'
      redirect_to new_user_invitation_path
    else
      invited_user = User.invite!(invite_params, current_user)
      if invited_user.errors.blank?
        invited_user.add_role(params[:role]) if params[:role].present?
        redirect_to users_path, notice: 'User has been invited successfully.'
      else
        flash.now[:alert] = 'There was an error inviting the user.'
        redirect_to new_user_invitation_path
      end
    end
  end

  private

  def invite_params
    params.require(:user).permit(:email, :first_name, :last_name, :client_id, roles: [])
  end

  def assign_role(invited_user)
    return unless params[:role].present?

    if current_user.has_role?(:admin)
      invited_user.add_role(params[:role])
    elsif current_user.has_role?(:project_manager)
      invited_user.add_role(params[:role]) unless params[:role] == 'admin'
    else
      invited_user.add_role(params[:role]) unless %w[admin project_manager].include?(params[:role])
    end
  end
end
