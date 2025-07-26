class RemoveNameAndDescriptionFromProduct < ActiveRecord::Migration[7.2]
  def change
    remove_column :products, :name, :string
    remove_column :products, :description, :text
  end
end
