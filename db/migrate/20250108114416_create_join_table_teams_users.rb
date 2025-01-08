class CreateJoinTableTeamsUsers < ActiveRecord::Migration[7.2]
  def change
    create_join_table :teams, :users, column_options: { type: :uuid } do |t|
      t.index [:team_id, :user_id]
      t.index [:user_id, :team_id]
    end
  end
end