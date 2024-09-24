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

  def show; end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.user_id = current_user.id
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

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully destroyed.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :start_date, :end_date, :image, :content, :scope, :fod, :brd,
                                    :user_id, images: [])
  end
end
