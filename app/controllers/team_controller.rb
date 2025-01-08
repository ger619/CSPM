class TeamController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index
    @per_page = 10
    @page = (params[:page] || 1).to_i

    @team = if params[:query].present?
              Team.where('name ILIKE :query OR description ILIKE :query', query: "%#{params[:query]}%")
            else
              Team.all.order('created_at DESC')
            end

    @total_pages = (@team.count / @per_page.to_f).ceil
    @team = @team.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @team_members = @team.users
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to team_index_path, notice: 'Team was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to team_path(@team), notice: 'Team was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to teams_path, notice: 'Team was successfully deleted.' }
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :description, user_ids: [])
  end
end
#       end
#     end
#   end
# end
#
#   def destroy
#     @team.destroy
#     respond_to do |format|
#       format.html { redirect_to teams_path, notice: 'Team was successfully deleted.' }
#     end
#   end
#
#   private
#
#   def set_team
#     @team = Team.find(params[:id
# end
