# frozen_string_literal: true

class PeintreTask < ApplicationRecord
  has_one :task, as: :taskable, dependent: :destroy

  # The self keyword before the method name indicates that this method is a class method, not an instance method. This means that you can call this method directly on the class itself (e.g., PeintreTask.permitted_attributes) rather than on an instance of the class.
  def self.permitted_attributes
    %i[
      #! String fields
      type_de_travaux
      type_de_surface
      nombre_de_logements
      nombre_de_pieces
      surface_sol
      surface_mur
      surface_plafond
      #! Boolean fields
      peinture_lisse
      gouttelette
      gouttelette_ecrase
      pose_revetement_tapisserie
      pose_revetement_toile_de_verre
      pose_revetement_type_vescom
      pose_sol_sans_soudure
      pose_sol_avec_soudure_a_chaux
      stuco_decoration
      peinture_facade
      pose_plaques_type_decochoc
      pose_faience
      pose_petite_platrerie
      pose_plinthe
      pose_parquet_fottant
      rattrapage_bande_placo
      ratissage
      pose_baguette_angles
      #! Text field
      other_task
    ]
  end
end
