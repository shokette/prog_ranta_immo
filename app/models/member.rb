class Member < ApplicationRecord
    has_many :hike_histories
    has_many :hikes, through: :hike_histories
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    belongs_to :role
end
