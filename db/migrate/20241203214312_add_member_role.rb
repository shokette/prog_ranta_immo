class AddMemberRole < ActiveRecord::Migration[7.0]
    def change
        ["guide", "membre"].each do |role_name|
            role = Role.find_by(name: role_name)
            Role.create(name: role_name) unless role.present?
        end
    end
end
