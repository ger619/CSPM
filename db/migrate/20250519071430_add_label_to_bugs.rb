class AddLabelToBugs < ActiveRecord::Migration[7.2]
  def change
    add_column :bugs, :label, :string
  end
end
