class CreateElectricienTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :electricien_tasks do |t|
      t.string :type_de_travaux
      t.string :type_de_batiment
      t.string :nombre_de_pieces
      t.string :surface_totale
      t.string :amperage_principal
      t.string :tension_requise
      t.string :phase_type

      # Boolean flags for specific tasks
      t.boolean :installation_tableau_electrique
      t.boolean :mise_aux_normes_tableau
      t.boolean :pose_prises_electriques
      t.boolean :pose_interrupteurs
      t.boolean :installation_eclairage
      t.boolean :pose_luminaires
      t.boolean :installation_cuisine
      t.boolean :installation_salle_de_bain
      t.boolean :installation_exterieure
      t.boolean :installation_cave_garage
      t.boolean :mise_a_la_terre
      t.boolean :installation_differentiel
      t.boolean :installation_parafoudre
      t.boolean :verification_conformite
      t.boolean :installation_domotique
      t.boolean :installation_videophone
      t.boolean :installation_alarme
      t.boolean :installation_ventilation
      t.boolean :depannage_urgent
      t.boolean :recherche_panne
      t.boolean :modification_existant
      t.boolean :passage_cables
      t.boolean :saignee_murs

      # Additional Information
      t.text :other_task
      t.timestamps
    end
  end
end
