class CreateFrames < ActiveRecord::Migration
  def change
    create_table :frames do |t|
      t.integer :frame_number, null: false
      t.integer :score, null: false, default: 0
      t.references :player
      
      t.timestamps null: false
    end
  end
end
