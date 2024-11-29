# frozen_string_literal: true

module SelectOption
  extend ActiveSupport::Concern

  LEGAL_STATUS = %w[SARL EURL SA SAS Auto-entrepreneur].freeze

  ACTIVITY_SECTORS = {
    'Aménagement & finitions' => [
      'Pro. Nettoyage du batiment',
      'Agenceur', 'Peintre', 'Platrier', 'Solier moquettiste', 'Carreleur'
    ],
    'Equipements techniques' => ['Electricien', 'Plombier',
                                 'Instal. chauffage & clim.'],
    'Enveloppe extérieure' => ['Cordiste', 'Couvreur', 'Etancheur',
                               'Menuiserie métallique', 'Miroitier', 'Storiste'],
    'Structure & gros oeuvre' => ['Charpentier bois', "Conducteur d'engins",
                                  'Constructeur bois', 'Constructeur en béton armé',
                                  'Constructeur en sols industriels', 'Constructeur métallique',
                                  'Démolisseur', 'Grutier', 'Maçon', "Monteur d'échafaudage",
                                  'Monteur levageur', 'Tailleur de pierre']
  }.freeze

  ACTIVITY_SECTORS_TRANSLATIONS = {
    en: {
      'Aménagement & finitions' => {
        name: 'Interior Design & Finishing',
        subsectors: {
          'Pro. Nettoyage du batiment' => 'Building Cleaning Pro.',
          'Agenceur' => 'Interior Designer',
          'Peintre' => 'Painter',
          'Platrier' => 'Plasterer',
          'Solier moquettiste' => 'Carpet Layer',
          'Carreleur' => 'Tile Setter'
        }
      },
      'Equipements techniques' => {
        name: 'Technical Equipment',
        subsectors: {
          'Electricien' => 'Electrician',
          'Plombier' => 'Plumber',
          'Instal. chauffage & clim.' => 'HVAC Installer'
        }
      },
      'Enveloppe extérieure' => {
        name: 'Building Envelope',
        subsectors: {
          'Cordiste' => 'Rope Access Technician',
          'Couvreur' => 'Roofer',
          'Etancheur' => 'Waterproofer',
          'Menuiserie métallique' => 'Metal Joinery',
          'Miroitier' => 'Glazier',
          'Storiste' => 'Blind Installer'
        }
      },
      'Structure & gros oeuvre' => {
        name: 'Structure & Shell Work',
        subsectors: {
          'Charpentier bois' => 'Wood Carpenter',
          "Conducteur d'engins" => 'Machine Operator',
          'Constructeur bois' => 'Wood Constructor',
          'Constructeur en béton armé' => 'Reinforced Concrete Constructor',
          'Constructeur en sols industriels' => 'Industrial Flooring Constructor',
          'Constructeur métallique' => 'Metal Constructor',
          'Démolisseur' => 'Demolition Worker',
          'Grutier' => 'Crane Operator',
          'Maçon' => 'Mason',
          "Monteur d'échafaudage" => 'Scaffolding Assembler',
          'Monteur levageur' => 'Lifting Assembler',
          'Tailleur de pierre' => 'Stone Mason'
        }
      }
    },
    fr: ACTIVITY_SECTORS
  }.freeze

  def self.translated_sectors
    locale = I18n.locale
    if locale == :fr
      ACTIVITY_SECTORS.transform_values do |subsectors|
        subsectors.map { |s| [s, s] }
      end
    else
      result = {}
      ACTIVITY_SECTORS.each do |sector, subsectors|
        translated_sector = ACTIVITY_SECTORS_TRANSLATIONS[:en][sector][:name]
        translated_subsectors = subsectors.map do |subsector|
          translated = ACTIVITY_SECTORS_TRANSLATIONS[:en][sector][:subsectors][subsector]
          [translated, subsector] # [displayed_value, stored_value]
        end
        result[translated_sector] = translated_subsectors
      end
      result
    end
  end

  # POSITION = ["Donneur-d'ordre", "Sous-traitant"].freeze
  POSITION = %w[contractor sub-contractor].freeze

  ESTABLISHMENT_YEARS = (1900..Time.current.year).to_a.reverse.freeze
end
