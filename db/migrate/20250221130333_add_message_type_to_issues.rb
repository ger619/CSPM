class AddMessageTypeToIssues < ActiveRecord::Migration[7.2]
  def change
    add_column :issues, :message_type, :string, default: "external"
  end
end
