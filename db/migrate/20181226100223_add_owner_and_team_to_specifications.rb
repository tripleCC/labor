class AddOwnerAndTeamToSpecifications < ActiveRecord::Migration
  def change
  	add_column :specifications, :owner, :string, null: true, default: '未知'
  	add_column :specifications, :team, :string, null: true, default: '未知'
  end
end
