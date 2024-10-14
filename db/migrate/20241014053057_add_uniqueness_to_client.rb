class AddUniquenessToClient < ActiveRecord::Migration[7.2]
  def change
    add_index :clients, :name, unique: true
    add_index :softwares, :name, unique: true
  end
end
