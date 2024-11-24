# frozen_string_literal: true

module SelectOption
  extend ActiveSupport::Concern

  LEGAL_STATUS = %w[SARL EURL SA SAS Auto-entrepreneur].freeze

  ACTIVITY_SECTORS = {
    "Aménagement & finitions" => [
      "Pro. Nettoyage du batiment",
      "Agenceur", "Peintre", "Platrier", "Solier moquettiste", "Carreleur",
    ],
    "Equipements techniques" => ["Electricien", "Plombier",
                                 "Instal. chauffage & clim."],
    "Enveloppe extérieure" => ["Cordiste", "Couvreur", "Etancheur",
                               "Menuiserie métallique", "Miroitier", "Storiste"],
    "Structure & gros oeuvre" => ["Charpentier bois", "Conducteur d'engins",
                                  "Constructeur bois", "Constructeur en béton armé",
                                  "Constructeur en sols industriels", "Constructeur métallique",
                                  "Démolisseur", "Grutier", "Maçon", "Monteur d'échafaudage",
                                  "Monteur levageur", "Tailleur de pierre"],
  }.freeze

  POSITION = ["Donneur-d'ordre", "Sous-traitant"].freeze

  ESTABLISHMENT_YEARS = (1900..Time.current.year).to_a.reverse.freeze
end
