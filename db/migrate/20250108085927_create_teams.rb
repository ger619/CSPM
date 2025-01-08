class CreateTeams < ActiveRecord::Migration[7.2]
  def change
    create_table :teams, id: :uuid do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
