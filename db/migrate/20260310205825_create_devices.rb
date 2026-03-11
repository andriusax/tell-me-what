class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :name
      t.text :description
      t.float :price
      t.string :picture_url
      t.references :artists, null: false, foreign_key: true

      t.timestamps
    end
  end
end
