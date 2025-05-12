class AddDocumentNamesToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :document_names, :text
  end
end
