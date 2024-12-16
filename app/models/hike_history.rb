class HikeHistory < ApplicationRecord
    belongs_to :hike
    belongs_to :member

    # Validations de présence pour tous les champs requis
    validates :hiking_date, presence: true
    validates :departure_time, presence: true

    # Validations numériques avec contraintes spécifiques
    validates :carpooling_cost,
              numericality: { greater_than_or_equal_to: 0, message: "doit être un nombre positif" },
              allow_blank: true
    validates :openrunner_ref,
              numericality: { only_integer: true, message: "doit être un nombre entier" },
              allow_blank: true
end