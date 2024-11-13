class CreateNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :nodes do |t|
      t.string :name, null: false
      t.string :lat, null: false
      t.string :lon, null: false

      t.timestamps
    end
  end
end
