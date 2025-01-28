class CreateBugs < ActiveRecord::Migration[7.2]
  def change
    create_table :bugs, id: :uuid do |t|
      t.string :issue
      t.string :priority

      t.timestamps
    end
  end
end
