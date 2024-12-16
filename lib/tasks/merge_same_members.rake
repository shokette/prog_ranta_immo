namespace :members do
    desc 'Import hikes from CSV file'
    task merge_same: :environment do
        # delete members that have the same name and number
        # and keep the one hikes histories
        members = Member.all
        members.each do |member|
            member_with_same_name_and_number = Member.where(name: member.name, phone: member.phone)
            if member_with_same_name_and_number.count > 1
                member_with_same_name_and_number.each do |member_to_delete|
                    if member_to_delete != member
                        member_to_delete.hike_histories.each do |hike_history|
                            hike_history.member_id = member.id
                            hike_history.save
                        end
                        member_to_delete.destroy
                    end
                end
            end
        end
    end
end