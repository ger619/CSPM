class AddNewFieldNameToRatings < ActiveRecord::Migration[7.2]
  def change
    add_column :ratings, :comment, :string
  end
end
