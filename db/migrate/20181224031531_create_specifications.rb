class CreateSpecifications < ActiveRecord::Migration
  def change
  	create_table :specifications do |t|
  		t.belongs_to :project, index: true
  		t.string :name
  		t.string :version
  		t.string :summary
			t.json :source, default: {}
			t.integer :spec_type, default: 2
			t.string :spec_external_dependency_names, array: true, default: []
  		t.text :spec_content
  		t.timestamps null: true
  	end
  end
end
