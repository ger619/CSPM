class RemoveNullConstrainFromBugs < ActiveRecord::Migration[7.2]
  def change
    change_column_null :bugs, :software_id, true
    change_column_null :bugs, :groupware_id, true
  end
end
