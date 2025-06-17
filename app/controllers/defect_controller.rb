class DefectController < ApplicationController
  before_action :set_defect, only: %i[show edit update destroy]

  def index
    @defects = Defect.all
  end

  def show; end

  def new
    @defect = Defect.new
  end

  def edit; end

  def create
    @defect = Defect.new(defect_params)
    if @defect.save
      redirect_to @defect, notice: 'Defect was successfully created.'
    else
      render :new
    end
  end

  def update
    if @defect.update(defect_params)
      redirect_to @defect, notice: 'Defect was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @defect.destroy
    redirect_to defects_url, notice: 'Defect was successfully destroyed.'
  end

  private

  def set_defect
    @defect = Defect.find(params[:id])
  end

  def defect_params
    params.require(:defect).permit(:name, :description, :start_date, :end_date, :product_id)
  end
end
