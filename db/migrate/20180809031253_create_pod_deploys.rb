class CreatePodDeploys < ActiveRecord::Migration
  def change
  	create_table :pod_deploys do |t|
  		t.belongs_to :main_deploy, index: true
  		t.string :name
  		t.string :project_id
  		t.string :repo_url, presence: true
  		t.string :ref, default: 'master'
  		t.string :version
  		t.string :pipeline_id
  		t.string :owner
  		t.string :owner_mobile
  		t.string :owner_ding_token
  		t.string :merge_request_iids, default: ''
  		t.string :status
  		t.string :failure_reason
  		t.datetime :started_at
	    t.datetime :finished_at
  		t.timestamps null: true
  	end
  end
end
