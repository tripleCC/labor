class CreateLeakInfos < ActiveRecord::Migration
  def change
  	create_table :leak_infos do |t|
  		t.belongs_to :user, index: true
  		t.belongs_to :app_info, index: true
  		t.string :name
  		t.text :trace
  		t.boolean :active, default: true
  		t.timestamps null: true
  	end

		# create_table :trace_infos do |t|
		# 	t.belongs_to :app_info, index: true
		# 	t.belongs_to :leak_info, index: true
  # 		t.string :name
  # 		t.boolean :active, default: true
  # 		t.timestamps null: true
  # 	end  	
  end
end
