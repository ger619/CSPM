class CreateJoinTableProductSoftware < ActiveRecord::Migration[7.2]
  def change
    create_join_table :products, :softwares, column_options: { type: :uuid } do |t|
      t.index [:product_id, :software_id], unique: true
      t.index [:software_id, :product_id], unique: true
    end
  end
end
