class CreateUsers < ActiveRecord::Migration
   def change
  	create_table :users do |t|
  		t.string :sub
  		t.string :nickname
  		t.string :email
  		t.string :phone_number
  		t.string :picture
  		t.boolean :superman, default: false
  		t.text :unofficial_names, array: true, default: []
  		t.timestamps null: true
  	end
  end
end
