class CreateCoordinates < ActiveRecord::Migration[7.1]
  def change
    create_table :coordinates do |t|
      t.float :lat, precision: 10, scale: 2, null: false
      t.float :long, precision: 10, scale: 2, null: false
      t.references :line, null: false, foreign_key: true
      t.index %i[lat long line_id], unique: true

      t.timestamps
    end
  end
end
