class CreateJoinTableProductStatus < ActiveRecord::Migration[7.2]
  def change
    create_join_table :products, :statuses,  column_options: { type: :uuid }  do |t|
      t.index [:product_id, :status_id]
      t.index [:status_id, :product_id]
    end
  end
end
