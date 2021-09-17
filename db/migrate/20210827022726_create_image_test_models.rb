class CreateImageTestModels < ActiveRecord::Migration[6.1]
  def change
    create_table :image_test_models do |t|
      t.string :title
      t.string :content

      t.timestamps
    end
  end
end
