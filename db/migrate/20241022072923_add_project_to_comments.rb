class AddProjectToComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :comments, :project,  foreign_key: true, type: :uuid
  end
end
