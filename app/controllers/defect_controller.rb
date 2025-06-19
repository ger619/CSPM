class DefectController < ApplicationController
  before_action :set_defect, only: %i[show edit update destroy add_defect]

  def index
    if current_user.has_role?(:admin) || current_user.has_role?(:observer) || current_user.has_role?(:agent) ||
       # show all defects or those relevant to the user
       (@defect = Defect.all)
    else
      @defect = Defect.none
    end
  end

  def show
    @bugs = @defect.bugs
    @bugs = @bugs.joins(:users).where(users: { id: current_user.id }) unless current_user.has_any_role?(:admin, :observer)
    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@bugs.count / @per_page.to_f).ceil
    @bugs = @bugs.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def new
    @defect = Defect.new
  end

  def edit; end

  def create
    @defect = Defect.new(defect_params)

    respond_to do |format|
      if @defect.save
        format.html { redirect_to defect_index_path, notice: 'Defect was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
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

  # add a user to the defect
  def add_defect
    if @defect.users.include?(User.find(params[:user_id]))
      redirect_to @defect, notice: 'User has already been assigned.'
    else
      user = User.find(params[:user_id])
      @defect.users << user
      redirect_to defect_path(@defect), notice: "#{@defect.users.name} was successfully assigned."
    end
  end

  private

  def set_defect
    @defect = Defect.find(params[:id])
  end

  def defect_params
    params.require(:defect).permit(:name, :description, :start_date, :end_date, :product_id, :user_id)
  end
end
