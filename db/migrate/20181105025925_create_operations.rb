class CreateOperations < ActiveRecord::Migration
  def change
  	create_table :operations do |t|
  		t.belongs_to :user, index: true
  		t.belongs_to :pod_deploy, index: true
  		t.belongs_to :main_deploy, index: true
  		t.string :name
  		t.timestamps null: true
  	end
  end
end
