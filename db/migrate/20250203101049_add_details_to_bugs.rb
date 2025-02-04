class AddDetailsToBugs < ActiveRecord::Migration[7.2]
  def change
    add_column :bugs, :summary, :string
    add_reference :bugs, :software, null: false, foreign_key: true, type: :uuid
    add_reference :bugs, :groupware, null: false, foreign_key: true, type: :uuid
  end
end
