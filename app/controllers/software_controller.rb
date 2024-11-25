class SoftwareController < ApplicationController
  before_action :authenticate_user!
  before_action :set_software, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index
    @software = Software.all

    @software = if params[:query].present?
                  @software.where('name ILIKE ? OR description ILIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
                else
                  @software.order('created_at DESC')
                end

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@software.count / @per_page.to_f).ceil
    @software = @software.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @software = Software.find(params[:id])
  end

  def new
    @software = Software.new
  end

  def create
    @software = Software.new(software_params)
    @software.user_id = current_user.id
    respond_to do |format|
      if current_user.has_role?(:admin)
        if @software.save
          format.html { redirect_to software_index_path, notice: 'Software was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path, alert: 'You are not authorized to create software.' }
      end
    end
  end

  def edit; end

  def destroy
    @software.destroy
    respond_to do |format|
      format.html { redirect_to software_index_path, notice: 'Software was successfully destroyed.' }
    end
  end

  def update
    respond_to do |format|
      if @software.update(software_params)
        format.html { redirect_to software_index_path, notice: 'Software was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity }
      end
    end
  end

  private

  def set_software
    @software = Software.find(params[:id])
  end

  def software_params
    params.require(:software).permit(:name, :description, :user_id)
  end
end
