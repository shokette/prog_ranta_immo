class AddTableGuides < ActiveRecord::Migration[7.0]
    def change
        unless table_exists? :guides
            create_table :guides do |t|
                t.string :name, null: false
                t.string :phone, null: false
                t.string :email
                t.timestamps
            end
        end


        if table_exists? :hike_histories
            add_column :hike_histories, :guide_id, :integer unless column_exists? :hike_histories, :guide_id
        end
    end
end
