class CreateProjects < ActiveRecord::Migration
  def change
  	create_table :projects do |t|
  		t.string :name
  		t.string :ssh_url_to_repo
  		t.string :http_url_to_repo
  		t.string :web_url
  		t.timestamps null: true
  	end

  	remove_column :pod_deploys, :project_id, :string
  	remove_column :main_deploys, :project_id, :string
  	add_reference :pod_deploys, :project, index: true
  	add_reference :main_deploys, :project, index: true
  end
end
