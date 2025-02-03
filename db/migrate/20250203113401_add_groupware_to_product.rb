class AddGroupwareToProduct < ActiveRecord::Migration[7.2]
  def change
    add_reference :products, :groupware, foreign_key: true, type: :uuid
  end
end
