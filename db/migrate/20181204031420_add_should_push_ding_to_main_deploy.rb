class AddShouldPushDingToMainDeploy < ActiveRecord::Migration
  def change
  	add_column :main_deploys, :should_push_ding, :boolean, default: true
  end
end
