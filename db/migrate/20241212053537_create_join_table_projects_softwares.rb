class CreateJoinTableProjectsSoftwares < ActiveRecord::Migration[7.2]
  def change
    create_join_table :projects, :softwares, column_options: { type: :uuid } do |t|
      # Adding indexes to improve query performance
      t.index [:project_id, :software_id], unique: true
      t.index [:software_id, :project_id], unique: true
    end
  end
end
