class ProductController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: %i[show edit update destroy manage_users]
  load_and_authorize_resource

  def index
    @product = Product.all

    @product = if params[:query].present?
                 @product.where('name ILIKE ? OR description ILIKE ?', "%#{params[:query]}%", "%#{params[:query]}%")
               else
                 @product.order('created_at DESC')
               end
    @product = @product.joins(:users).where(users: { id: current_user.id }) unless current_user.has_any_role?(:admin, :observer)

    @per_page = 12
    @page = (params[:page] || 1).to_i
    @total_pages = (@product.count / @per_page.to_f).ceil
    # show the count for the page
    @start_count = ((@page - 1) * @per_page) + 1
    @end_count = [@page * @per_page, @product.count].min
    @total_count = @product.count
    @product = @product.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    if current_user.has_role?(:admin) || @product.users.include?(current_user)
      # @boards = preferred_order.flat_map do |status|
      boards = @product.boards.includes(:tasks).where(status: status)
      boards.joins(:tasks).where('tasks.name ILIKE ?', "%#{params[:query]}%") if params[:query].present?
      # end

      # Only override if no search query is present:
      @boards = @product.boards unless params[:query].present?

      @todo_board = @boards.find { |board| board.status == 'TO DO' } || @boards.first
      @days_remaining = (@product.end_date - Date.today).to_i if @product.end_date.present?

      # Show the count of the tasks per status in the product boards
      @product.boards.pluck(:status).uniq
      # task_counts = Task.joins(:board)
      #  .where(boards: { product_id: @product.id })
      #  .group('boards.status')
      #  .count

      # Define status groups
      @open_statuses = ['TO DO', 'In Progress', 'On-Hold', 'Failed-QA', 'QA-testing',
                        'Await Client Information', 'Reopened',
                        'Awaiting Build', 'Support Testing', 'Awaiting Client API']
      @closed_statuses = %w[Blocked Resolved Closed]
      @awaiting_client_statuses = ['Await Client Information', 'Awaiting Client API']

      # Apply filtering if status param is present
      if params[:filter].present?
        case params[:filter]
        when 'open'
          @tasks = @product.tasks.joins(:board).where(boards: { status: @open_statuses })
        when 'closed'
          @tasks = @product.tasks.joins(:board).where(boards: { status: @closed_statuses })
        when 'awaiting_client'
          @tasks = @product.tasks.joins(:board).where(boards: { status: @awaiting_client_statuses })
        when 'my_open_tasks'
          @tasks = @product.tasks
            .joins(:board, :users)
            .where(boards: { status: @open_statuses })
            .where(users: { id: current_user.id })
        end
      else
        @tasks = @product.tasks
      end

      # Group filtered tasks by board (always run this)
      # @filtered_tasks_by_board = @tasks.group_by(&:board_id)

      # Get counts for each status group
      # @open_tasks_count = @product.tasks.joins(:board).where(boards: { status: @open_statuses }).count
      # @closed_tasks_count = @product.tasks.joins(:board).where(boards: { status: @closed_statuses }).count
      # @awaiting_client_tasks_count = @product.tasks.joins(:board).where(boards: { status: @awaiting_client_statuses }).count
      # @my_open_tasks = @product.tasks
      # .joins(:board, :users)
      #  .where(boards: { status: @open_statuses })
      #  .where(users: { id: current_user.id })
      #   .count

      # @product_tasks_per_board_status = board_statuses.index_with { |status| task_counts[status] || 0 }

    else
      redirect_to root_path, alert: 'You are not authorized to view this content.'
    end
  end

  def manage_users
    respond_to do |format|
      format.html
      format.turbo_stream
    end

    render layout: false
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
          # Save the selected software
          @product.softwares = Software.where(id: params[:product][:software_ids])

          # Save the selected groupware only if it is selected
          if params[:product][:groupware_ids].present?
            @product.groupwares = Groupware.where(id: params[:product][:groupware_ids])
          else
            @product.groupwares.clear
          end

          # Save the select script onlyd if it is elected
          if params[:product][:script_ids].present?
            @product.scripts = Script.where(id: params[:product][:script_ids])
          else
            @product.scripts.clear
          end

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

  def edit
    @product.documents.build if @product.documents.empty?
  end

  def update
    if @product.update(product_params)
      redirect_to product_path(@product), notice: 'Product was successfully updated.'
    else
      Sentry.capture_message('Product update failed', extra: { errors: @product.errors.full_messages, params: params })
      render :edit, status: :unprocessable_entity
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

  def product_status
    @product = Product.find(params[:id])
    status = Status.find(params[:status_id])
    @product.statuses.clear
    @product.statuses << status
    redirect_to @product, notice: 'Product status was successfully updated.'
  end

  def remove_user
    @product = Product.find(params[:id])
    user = User.find(params[:user_id])
    @product.users.delete(user)
    redirect_to @product, notice: 'User was successfully removed.'
  end

  def destroy
    @product.destroy
    redirect_to product_index_path, notice: 'Product was successfully destroyed.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :start_date, :end_date, :document_name, :image, :content,
                                    :user_id, :client_id, images: [], software_ids: [], groupware_ids: [],
                                                          documents_attributes: %i[id name file _destroy])
  end
end
