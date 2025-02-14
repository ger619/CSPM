class AddSpecialToProject < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :special, :boolean, default: false
  end
end
