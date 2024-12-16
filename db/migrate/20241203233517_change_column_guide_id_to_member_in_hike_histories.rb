class ChangeColumnGuideIdToMemberInHikeHistories < ActiveRecord::Migration[7.0]
    def change
        rename_column :hike_histories, :guide_id, :member_id if column_exists? :hike_histories, :guide_id
    end
end
