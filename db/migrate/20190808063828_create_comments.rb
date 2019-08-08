class CreateComments < ActiveRecord::Migration
  def change
  	create_table :comments do |t|
  		t.belongs_to :user, index: true
  		t.belongs_to :leak_info, index: true
  		t.string :user_name
  		t.text :content
  		t.timestamps null: true
  	end
  end
end