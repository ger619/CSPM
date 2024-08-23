# app/controllers/invitations_controller.rb
class InvitationsController < Devise::InvitationsController
  before_action :authenticate_user!
  # before_action :set_user, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    invited_user = User.invite!(invite_params, current_user)

    if invited_user.errors.blank?
      invited_user.add_role(params[:role]) if params[:role].present?
      redirect_to users_path, notice: 'User has been invited successfully.'
    else
      Rails.logger.debug invited_user.errors.full_messages.to_sentence
      flash.now[:alert] = 'There was an error inviting the user.'
      render :new
    end
  end

  private

  def invite_params
    params.require(:user).permit(:email)
  end
end
