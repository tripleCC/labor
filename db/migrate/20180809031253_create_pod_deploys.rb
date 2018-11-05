class CreatePodDeploys < ActiveRecord::Migration
  def change
  	create_table :pod_deploys do |t|
      t.belongs_to :user, index: true
  		t.belongs_to :main_deploy, index: true
  		t.string :name
  		t.string :project_id
  		t.string :repo_url, presence: true
  		t.string :ref, default: 'master'
  		t.string :version
  		# t.string :external_dependency_names, default: ''
      t.text :external_dependency_names, array: true, default: []
  		t.string :mr_pipeline_id
  		t.string :cd_pipeline_id
  		t.string :owner
  		t.string :owner_mobile
  		t.string :owner_ding_token
  		# t.string :merge_request_iids, default: ''
      t.text :merge_request_iids, array: true, default: []
  		t.string :status
  		t.string :failure_reason
  		t.boolean :reviewed, default: false, null: false
      t.boolean :manual, default: false, null: false
  		t.datetime :started_at
	    t.datetime :finished_at
  		t.timestamps null: true
  	end
  end
end
