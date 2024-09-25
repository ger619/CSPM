class BoardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_board, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index; end

  def new
    @boards = Board.new
  end

  def create
    @boards = @product.boards.new(board_params)
    @boards.user = current_user

    respond_to do |format|
      if @boards.save
        current_user.add_role :creator, @board
        format.html { redirect_to product_path(@product), notice: 'Board was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show; end

  def edit; end

  def update
    respond_to do |format|
      if @boards.update(board_params)
        current_user.add_role :editor, @board
        format.html { redirect_to product_path(@product.id), notice: 'Board was successfully updated.' }
      else
        format.html { render 'edit', status: :unprocessable_entity, alert: 'Board was not updated.' }
      end
    end
  end

  def destroy
    @boards.destroy
    redirect_to product_path(@product)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_board
    @boards = @product.boards.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:status, :product_id)
  end
end
