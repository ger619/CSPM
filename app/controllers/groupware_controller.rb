class GroupwareController < ApplicationController
  before_action :authenticate_user!
  before_action :software
  before_action :set_groupware, only: %i[show edit update destroy]

  def index
    @groupwares = Groupware.all
  end

  def new
    @groupware = @software.groupwares.new
  end

  def create
    @groupware = @software.groupwares.new(groupware_params)

    respond_to do |format|
      if @groupware.save
        format.html { redirect_to software_groupwares_path(@software), notice: 'Groupware was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def software
    @software = Software.find(params[:software_id])
  end

  def set_groupware
    @groupware = @software.groupwares.find(params[:id])
  end
end
