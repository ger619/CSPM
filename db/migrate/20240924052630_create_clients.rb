class CreateClients < ActiveRecord::Migration[7.2]
  def change
    create_table :clients, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.string :client_contact_person
      t.string :client_contact_phone_number
      t.string :client_contact_person_email
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
