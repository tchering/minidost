class ElectricienTask < ApplicationRecord
  has_one :task, as: :taskable, dependent: :destroy

  def self.permitted_attributes
    %i[
      #! String fields
      type_de_travaux
      type_de_batiment
      nombre_de_pieces
      surface_totale
      amperage_principal
      tension_requise
      phase_type
      #! Boolean fields
      installation_tableau_electrique
      mise_aux_normes_tableau
      pose_prises_electriques
      pose_interrupteurs
      installation_eclairage
      pose_luminaires
      installation_cuisine
      installation_salle_de_bain
      installation_exterieure
      installation_cave_garage
      mise_a_la_terre
      installation_differentiel
      installation_parafoudre
      verification_conformite
      installation_domotique
      installation_videophone
      installation_alarme
      installation_ventilation
      depannage_urgent
      recherche_panne
      modification_existant
      passage_cables
      saignee_murs
      #! Text field
      other_task
    ]
  end
end
