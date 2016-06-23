class AddRollOneColumnToFrame < ActiveRecord::Migration
  def change
    add_column :frames, :roll_one, :integer
    add_column :frames, :roll_two, :integer
    add_column :frames, :roll_three, :integer
  end
end
