class AddScriptToBugs < ActiveRecord::Migration[7.2]
  def change
    add_reference :bugs, :script, foreign_key: true, type: :uuid
  end
end
