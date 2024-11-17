class CreateLines < ActiveRecord::Migration[7.1]
  def change
    create_table :lines do |t|
      t.string :name

      t.timestamps
    end
  end
end
