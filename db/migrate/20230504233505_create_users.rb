class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :country
      t.string :email
      t.boolean :verified
      t.string :role
      t.string :password_digest
      t.string :reset_password_token, null: true

      t.timestamps
    end
  end
end