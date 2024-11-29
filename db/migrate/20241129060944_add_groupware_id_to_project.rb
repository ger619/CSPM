class AddGroupwareIdToProject < ActiveRecord::Migration[7.2]
  def change
    add_reference :projects, :groupware, foreign_key: true, type: :uuid
  end
end
