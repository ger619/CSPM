class CreateJoinTableProjectsGroupwares < ActiveRecord::Migration[7.2]
  def change
    create_join_table :projects, :groupwares, column_options: { type: :uuid } do |t|
      # Adding indexes to improve query performance
      t.index [:project_id, :groupware_id], unique: true
      t.index [:groupware_id, :project_id], unique: true
    end
  end
end
