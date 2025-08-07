class AddSubModuleToDefects < ActiveRecord::Migration[7.2]
  def change
    add_column :defects, :submodule, :string
  end
end
