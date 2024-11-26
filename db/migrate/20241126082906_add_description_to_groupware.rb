class AddDescriptionToGroupware < ActiveRecord::Migration[7.2]
  def change
    add_column :groupwares, :description, :string
  end
end
