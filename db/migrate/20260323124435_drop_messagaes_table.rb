class DropMessagaesTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :messagaes
  end
end
