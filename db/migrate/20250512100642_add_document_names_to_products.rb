class AddDocumentNamesToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :document_name, :text
  end
end
