class AddCreatedByIdToDeals < ActiveRecord::Migration[7.0]
  def change
    add_column :deals, :created_by_id, :integer, null: true
    add_index :deals, :created_by_id
    add_foreign_key :deals, :users, column: :created_by_id, on_delete: :nullify
  end
end
