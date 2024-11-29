class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[edit update]

  def index
    @users = User.order('created_at DESC')
    if params[:query].present?
      @users = @users.where('email ILIKE :query OR first_name ILIKE :query OR last_name LIKE :query',
                            query: "%#{params[:query]}%")
    end
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

  def search
    users = User.where('first_name ILIKE ?', "%#{params[:q]}%").limit(10)
    render json: users.select(:id, :first_name, :last_name)
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
        if params[:role_ids].present? && (admin_role = Role.find_by(name: 'admin'))
          params[:role_ids] -= [admin_role.id.to_s]
        end
      end
    end
  end
end
