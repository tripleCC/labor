class CreateTags < ActiveRecord::Migration
  def change
  	create_table :tags do |t|
  		t.belongs_to :pod_deploy, index: true
  		t.string :name
  		# The target will contain the tag objects ID when creating annotated tags, 
  		# otherwise it will contain the commit ID when creating lightweight tags. 
  		t.string :target
  		t.string :message
  		t.string :sha
  		t.timestamps null: true
  	end
  end
end
