class InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!

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

    existing_user = User.find_by(
      email: invite_params[:email],
      first_name: invite_params[:first_name],
      last_name: invite_params[:last_name],
      client_id: invite_params[:client_id]
    )

    if existing_user
      flash[:alert] = 'User already exists.'
      redirect_to new_user_invitation_path
    else
      # Invite user directly – DeviseInvitable handles validations and token setup
      invited_user = User.invite!(invite_params, current_user)

      if invited_user.errors.blank?
        assign_role(invited_user) # ✅ Assign role after successful invitation
        redirect_to users_path, notice: 'User has been invited successfully.'
      else
        flash[:alert] = 'There was an error inviting the user.'
        redirect_to new_user_invitation_path
      end
    end
  end

  private

  def invite_params
    params.require(:user).permit(:email, :first_name, :last_name, :client_id, roles: [])
  end

  def assign_role(user)
    return unless params[:role].present?

    role = params[:role]

    if current_user.has_role?(:admin)
      user.add_role(role)
    elsif current_user.has_role?(:project_manager)
      user.add_role(role) unless role == 'admin'
    else
      user.add_role(role) unless %w[admin project_manager].include?(role)
    end
  end
end
