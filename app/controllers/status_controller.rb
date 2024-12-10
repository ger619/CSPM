class StatusController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index
    @status = Status.all

    @status = if params[:query].present?
                @status.where('name ILIKE ?', "%#{params[:query]}%")
              else
                @status.order('created_at DESC')
              end

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@status.count / @per_page.to_f).ceil
    @status = @status.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @status = Status.find(params[:id])
  end

  def new
    @status = Status.new
  end

  def create
    @status = Status.new(status_params)
    @status.user_id = current_user.id
    respond_to do |format|
      if @status.save
        format.html { redirect_to status_index_path, notice: 'Status was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @status.update(status_params)
        format.html { redirect_to status_index_path, notice: 'Status was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Status was not updated.' }
      end
    end
  end

  def destroy
    @status.destroy
    redirect_to status_index_path
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end

  def status_params
    params.require(:status).permit(:name)
  end
end
