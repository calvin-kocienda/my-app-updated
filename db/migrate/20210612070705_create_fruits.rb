class CreateFruits < ActiveRecord::Migration[6.1]
  def change
    create_table :fruits do |t|
      t.integer :apple
      t.integer :banana
      t.integer :orange
      t.integer :peach

      t.timestamps
    end
  end
end
