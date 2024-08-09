class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :title
      t.string :description
      t.date :start_date
      t.date :end_date
      t.references :user, null: false, foreign_key: true, type: :uuid


      t.timestamps
    end
  end
end
