class ProductController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index
    @product = Product.all

    @product = if params[:query].present?
                 @product.where('name ILIKE ? OR description ILIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
               else
                 @product.order('created_at DESC')
               end
    @product = @product.joins(:users).where(users: { id: current_user.id }) unless current_user.has_any_role?(:admin, :observer)

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@product.count / @per_page.to_f).ceil
    @product = @product.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    if current_user.has_role?(:admin) || @product.users.include?(current_user)
      preferred_order = ['TO DO', 'In Progress', 'On-Hold', 'Failed-QA', 'QA-testing', 'Blocked',
                         'Await Client Information', 'Reopened', 'Awaiting Build', 'Support Testing',
                         'Awaiting Client API', 'Resolved', 'Closed']
      @boards = preferred_order.flat_map do |status|
        boards = @product.boards.includes(:tasks).where(status: status)
        boards = boards.joins(:tasks).where('tasks.name ILIKE ?', "%#{params[:query]}%") if params[:query].present?
        boards
      end

      @bugs = @product.bugs

    else
      redirect_to root_path, alert: 'You are not authorized to view this content.'
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user_id = current_user.id

    # Validate presence of name, description, and content (subject)
    @product.errors.add(:name, "can't be blank") if @product.name.blank?
    @product.errors.add(:description, "can't be blank") if @product.description.blank?
    @product.errors.add(:content, "can't be blank") if @product.content.blank?

    respond_to do |format|
      if (current_user.has_role?(:admin) || current_user.has_role?('project_manager')) && @product.errors.empty?
        if @product.save
          current_user.add_role :creator, @product
          format.html { redirect_to product_path(@product), notice: 'Product was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        format.html do
          render :new, status: :unprocessable_entity, notice: 'You are not authorized to create a product.'
        end
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @product.update(product_params)
        current_user.add_role :editor, @product
        format.html { redirect_to product_path(@product), notice: 'Product was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity }
      end
    end
  end

  def add_user
    if @product.users.include?(User.find(params[:user_id]))
      redirect_to @product, notice: 'User has already been assigned.'
    else
      @product = Product.find(params[:id])
      user = User.find(params[:user_id])
      @product.user = current_user
      @product.users << user

      assigned_user = user
      UserMailer.assign_product_email(@product.user, @product, current_user, assigned_user).deliver_later
      # @product.users.each do |product_user|
      #  next if product_user == current_user

      # UserMailer.assign_product_email(product_user, @product, current_user, assigned_user).deliver_later
      # end

      redirect_to @product, notice: 'User was successfully assigned.'
    end
  end

  def remove_user
    @product = Product.find(params[:id])
    user = User.find(params[:user_id])
    @product.users.delete(user)
    redirect_to @product, notice: 'User was successfully removed.'
  end

  def destroy
    @product.destroy
    redirect_to product_url, notice: 'Product was successfully destroyed.'
  end

  def groupwares
    software_id = params[:software_id]
    # Fetch groupwares associated with the current project and the selected software_id
    groupwares = @product.groupwares
      .joins(:softwares)
      .where(softwares: { id: software_id })
      .distinct
    render json: groupwares
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :start_date, :end_date, :image, :content, :scope, :fod, :brd,
                                    :plan, :user_id, :client_id, images: [], software_ids: [], groupware_ids: [])
  end
end
