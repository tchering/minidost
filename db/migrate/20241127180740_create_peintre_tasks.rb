class CreatePeintreTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :peintre_tasks do |t|
      t.string :type_de_travaux
      t.string :type_de_surface
      t.string :nombre_de_logements
      t.string :nombre_de_pieces
      t.string :surface_sol
      t.string :surface_mur
      t.string :surface_plafond
      t.boolean :peinture_lisse
      t.boolean :gouttelette
      t.boolean :gouttelette_ecrase
      t.boolean :pose_revetement_tapisserie
      t.boolean :pose_revetement_toile_de_verre
      t.boolean :pose_revetement_type_vescom
      t.boolean :pose_sol_sans_soudure
      t.boolean :pose_sol_avec_soudure_a_chaux
      t.boolean :stuco_decoration
      t.boolean :peinture_facade
      t.boolean :pose_plaques_type_decochoc
      t.boolean :pose_faience
      t.boolean :pose_petite_platrerie
      t.boolean :pose_plinthe
      t.boolean :pose_parquet_fottant
      t.boolean :rattrapage_bande_placo
      t.boolean :ratissage
      t.boolean :pose_baguette_angles
      t.text :other_task

      t.timestamps
    end
  end
end
