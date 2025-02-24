class AddNameAndDescriptionToScripts < ActiveRecord::Migration[7.2]
  def change
    add_column :scripts, :name, :string
    add_column :scripts, :description, :text
  end
end
