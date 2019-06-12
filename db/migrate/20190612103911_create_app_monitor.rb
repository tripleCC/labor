class CreateAppMonitor < ActiveRecord::Migration
  def change
  	create_table :applications do |t|
  		t.string :name
  		t.string :version
  		t.timestamps null: true
  	end

  	create_table :operation_systems do |t|
  		t.string :name
  		t.string :version
  		t.timestamps null: true
  	end

  	create_table :load_duration_pairs do |t|
  		t.belongs_to :launch_info, index: true
  		t.string :name
  		t.string :duration
  		t.timestamps null: true
  	end

  	create_table :launch_infos do |t|
  		t.belongs_to :application, index: true
  		t.belongs_to :operation_system, index: true
  		t.string :will_to_did
  		t.string :start_to_did
  		t.string :load_total
  		t.timestamps null: true
  	end
  end
end
