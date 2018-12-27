class AddPlatformTypeToSpecifications < ActiveRecord::Migration
  def change
  	add_column :specifications, :platform_type, :integer, default: 0, null: false
  	change_column :name, :string, presence: true
  	change_column :version, :string, presence: true
  end
end
