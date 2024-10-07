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

    @per_page = 10
    @page = (params[:page] || 1).to_i
    @total_pages = (@product.count / @per_page.to_f).ceil
    @product = @product.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    # Display boards of the project
    if current_user.has_role?(:admin) || @product.users.include?(current_user)
      preferred_order = ['TO DO', 'In Progress', 'On-Hold', 'Failed-QA', 'QA-testing', 'Blocked',
                         'Await Client Information', 'Reopened', 'Awaiting Build', 'Support Testing',
                         'Awaiting Client API', 'Resolved', 'Closed']
      @boards = preferred_order.flat_map do |status|
        @product.boards.includes(:tasks).where(status:)
      end
    else
      redirect_to root_path, alert: 'You are not authorized to view this content.'
    end

    # @ticket = if params[:query].present?
    #            @project.tickets.left_joins(:rich_text_body).where('action_text_rich_texts.body ILIKE ?',
    #                                                               "%#{params[:query]}%")
    #          else
    #            @project.tickets.with_rich_text_body.order('created_at DESC')
    #          end
    # @per_page = 10
    # @page = (params[:page] || 1).to_i
    # @total_pages = (@ticket.count / @per_page.to_f).ceil
    # @ticket = @ticket.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user_id = current_user.id
    respond_to do |format|
      if current_user.has_role?(:admin) || current_user.has_role?('project_manager')
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

      # Send email to the newly assigned user
      UserMailer.assign_product_email(user, @product, current_user).deliver_later

      # Send email to all users assigned to the project, except the current user
      @product.users.each do |product_user|
        next if product_user == current_user

        UserMailer.assign_product_email(product_user, @product, current_user).deliver_later
      end

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

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :start_date, :end_date, :image, :content, :scope, :fod, :brd,
                                    :plan, :user_id, :client_id, images: [])
  end
end
