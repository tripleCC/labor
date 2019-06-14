class CreateDevices < ActiveRecord::Migration
  def change
  	create_table :devices do |t|
  		t.string :name
  		t.string :simple_name
  		t.datetime :created_at, null: true
  	end

  	add_reference :launch_infos, :device, index: true
  end
end
