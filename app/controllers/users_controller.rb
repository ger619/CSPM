class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[edit update]

  def index
    @users = User.all.order('created_at DESC')

    # Pagination for users
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@users.count / @per_page.to_f).ceil
    @users = @users.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def edit; end

  def update
    respond_to do |format|
      if @user.update(filtered_user_params)
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
    params.require(:user).permit(role_ids: [])
  end

  def filtered_user_params
    if current_user.has_role?(:admin)
      user_params
    else
      user_params.tap do |params|
        params[:role_ids] -= [Role.find_by(name: 'admin').id.to_s]
      end
    end
  end
end
