class CreatePipelines < ActiveRecord::Migration
  def change
  	create_table :pipelines do |t|
  		t.belongs_to :pod_deploy, index: true
  		t.string :pid
  		t.string :sha
  		t.string :ref
  		t.string :status
  		t.string :web_url
  		t.boolean :tag
  		t.timestamps null: true
  	end
  end
end
