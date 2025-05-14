class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :name
      t.references :product, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
