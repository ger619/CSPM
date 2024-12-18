class GroupwaresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_software
  before_action :set_groupware, only: %i[edit update destroy]

  def index
    if params[:project_id]
      project = Project.find(params[:project_id])
      groupwares = project.groupwares.where(software_id: params[:software_id])
    else
      groupwares = Groupware.where(software_id: params[:software_id])
    end

    render json: groupwares
  end

  def new
    @groupware = @software.groupwares.new
  end

  def create
    @groupware = @software.groupwares.new(groupware_params)

    respond_to do |format|
      if @groupware.save
        format.html { redirect_to software_path(@software), notice: 'Groupware was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @groupware.update(groupware_params)
        format.html { redirect_to software_path(@software), notice: 'Groupware was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @groupware.destroy
    respond_to do |format|
      format.html { redirect_to software_path(@software), notice: 'Groupware was successfully destroyed.' }
    end
  end

  private

  def set_software
    @software = Software.find(params[:software_id])
  end

  def set_groupware
    @groupware = @software.groupwares.find(params[:id])
  end

  def groupware_params
    params.require(:groupware).permit(:name, :software_id, :description)
  end
end
