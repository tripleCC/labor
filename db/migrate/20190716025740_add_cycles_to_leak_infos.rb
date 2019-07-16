class AddCyclesToLeakInfos < ActiveRecord::Migration
  def change
  	add_column :leak_infos, :cycles, :text, null: true
  end
end
