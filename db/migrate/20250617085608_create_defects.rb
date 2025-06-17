class CreateDefects < ActiveRecord::Migration[7.2]
  def change
    create_table :defects, id: :uuid do |t|
      t.string :name
      t.string :description
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
