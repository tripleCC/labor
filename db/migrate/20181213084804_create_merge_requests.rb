class CreateMergeRequests < ActiveRecord::Migration
  def change
  	create_table :merge_requests do |t|
  		t.belongs_to :pod_deploy, index: true
  		t.string :mid 
  		t.string :miid 
  		t.string :title
  		t.string :sha
  		t.string :state, default: "opened"
  		t.string :merge_status, default: "unchecked"
  		t.string :target_branch
  		t.string :source_branch
  		t.string :web_url
  		t.boolean :merge_when_pipeline_succeeds, default: false
  		t.timestamps null: true
  	end
  end
end
