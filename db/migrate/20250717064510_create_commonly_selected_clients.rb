class CreateCommonlySelectedClients < ActiveRecord::Migration[7.2]
  def change
    create_table :commonly_selected_clients, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :client, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
