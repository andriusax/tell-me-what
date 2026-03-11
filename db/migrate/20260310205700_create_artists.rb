class CreateArtists < ActiveRecord::Migration[8.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :located
      t.string :genre
      t.string :picture_url

      t.timestamps
    end
  end
end
