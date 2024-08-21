class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ edit update]

  def index
    @users = User.all.order('created_at DESC')
  end

  def edit; end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(role_ids: [] )
  end
end
