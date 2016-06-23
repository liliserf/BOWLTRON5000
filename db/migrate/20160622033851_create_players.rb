class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.references :game
      t.integer :running_total, null: false, default: 0

      t.timestamps null: false
    end
  end
end
