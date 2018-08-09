class CreateMainDeploys < ActiveRecord::Migration
  def change
  	create_table :main_deploys do |t|
  		t.string :name, presence: true
  		t.string :repo_url, presence: true
  		t.string :ref, presence: true
  		t.string :status
  		t.string :failure_reason
  		t.datetime :started_at
	    t.datetime :finished_at
  		t.timestamps null: true
  	end
  end
end
