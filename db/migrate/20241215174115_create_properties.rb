class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    unless table_exists?(:properties)
      create_table :properties do |t|
        t.string :title
        t.string :url
        t.float :price
        t.string :property_type
        t.string :location
        t.float :surface
        t.float :rooms

        t.timestamps
      end
    end
  end
end


