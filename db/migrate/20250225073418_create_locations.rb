class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :city
      t.string :country

      t.timestamps
    end
  end
end
