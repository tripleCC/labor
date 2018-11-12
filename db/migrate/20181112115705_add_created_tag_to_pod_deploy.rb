class AddCreatedTagToPodDeploy < ActiveRecord::Migration
  def change
  	add_column :pod_deploys, :created_tags, :string, array: true, default: []
  end
end
