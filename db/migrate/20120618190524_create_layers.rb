class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|

      t.timestamps
    end
  end
end
