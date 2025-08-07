class CreateMilestones < ActiveRecord::Migration[7.2]
  def change
    create_table :milestones, id: :uuid do |t|
      t.references :product, null: false, foreign_key: true, type: :uuid
      t.references :status, null: false, foreign_key: true, type: :uuid
      t.decimal :percentage, precision: 5, scale: 2
      t.integer :amount
      t.integer :position

      t.timestamps
    end
  end
end
