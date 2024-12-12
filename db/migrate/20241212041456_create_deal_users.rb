class CreateDealUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :deal_users do |t|
      t.references :deal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :deal_users, %i[deal_id user_id], unique: true, name: 'index_deal_users_on_deal_id_and_user_id'
  end
end
