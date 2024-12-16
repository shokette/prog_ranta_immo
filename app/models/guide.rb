class Guide < ApplicationRecord
    has_many :hike_histories
    has_many :hikes, through: :hike_histories
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    has_one :role
end
