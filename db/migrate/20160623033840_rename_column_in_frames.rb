class RenameColumnInFrames < ActiveRecord::Migration
  def change
    rename_column :frames, :roll_one, :roll_one_val
    rename_column :frames, :roll_two, :roll_two_val
    rename_column :frames, :roll_three, :roll_three_val
  end
end
