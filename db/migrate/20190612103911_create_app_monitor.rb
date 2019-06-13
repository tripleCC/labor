class CreateAppMonitor < ActiveRecord::Migration
  def change
  	create_table :app_infos do |t|
  		t.string :name
  		t.string :version
  		t.datetime :created_at, null: true
  	end

  	create_table :os_infos do |t|
  		t.string :name
  		t.string :version
  		t.datetime :created_at, null: true
  	end

  	create_table :load_duration_pairs do |t|
  		t.belongs_to :launch_info, index: true
  		t.string :name
  		t.string :duration
  		t.datetime :created_at, null: true
  	end

  	create_table :launch_infos do |t|
  		t.belongs_to :app_info, index: true
  		t.belongs_to :os_info, index: true
  		t.string :will_to_did
  		t.string :start_to_did
  		t.string :load_total
  		t.timestamps null: true
  	end
  end
end
