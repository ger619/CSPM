class CreateScripts < ActiveRecord::Migration[7.2]
  def change
    create_table :scripts, id: :uuid do |t|
      t.string :module
      t.references :groupware, null: false, foreign_key: true, type: :uuid
      t.references :software, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
