class AddDeployToOperation < ActiveRecord::Migration
  def change
  	remove_reference :operations, :pod_deploy, index: true
  	remove_reference :operations, :main_deploy, index: true
  	add_column :operations, :deploy_name, :string
  	add_column :operations, :deploy_type, :integer, default: 0
  end
end
