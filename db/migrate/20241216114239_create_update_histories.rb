class CreateUpdateHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :update_histories, id: :uuid do |t|
      t.uuid :ticket_id
      t.uuid :user_id
      t.json :change_details, null: false, default: {}
      t.datetime :updated_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
