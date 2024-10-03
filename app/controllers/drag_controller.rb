class DragController < ApplicationController
  def board; end

  private

  def drag_board_params
    params.require(:resource).permit(:id, :position)
  end
end
