class AddStatusColumnToFrame < ActiveRecord::Migration
  def change
    add_column :frames, :status, :string, default: "open"
  end
end
