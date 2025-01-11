class AddDefaultToMessageTypeInMessages < ActiveRecord::Migration[7.2]
  def change
    change_column_default :messages, :message_type, 'external'
  end
end
