class CreateJoinTableDefectsusers < ActiveRecord::Migration[7.2]
  def change
    create_join_table :defects, :users, column_options: { type: :uuid } do |t|
      t.index [:defect_id, :user_id]
      t.index [:user_id, :defect_id]
    end
  end
end
