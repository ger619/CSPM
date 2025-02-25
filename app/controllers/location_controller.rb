class LocationController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index
    @location = Location.all
    @location = if params[:query].present?
                  query = "%#{sanitize_sql_like(params[:query])}%" # Sanitize the query
                  @location.where(
                    'city ILIKE :query OR country ILIKE :query', query: query
                  )
                else
                  @location.order(created_at: :desc)
                end

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@location.count / @per_page.to_f).ceil
    @location = @location.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    @location.user_id = current_user.id

    respond_to do |format|
      if current_user.has_role?(:admin)
        if @location.save
          format.html { redirect_to location_index_path, notice: 'Location was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        format.html do
          render :new, status: :unprocessable_entity, notice: 'You are not authorized to create a location.'
        end
      end
    end
  end

  def show; end

  def location_params
    params.require(:location).permit(:city, :country)
  end
end
