#! -->2 app/decorators/peintre_task_pdf_decorator.rb
class PeintreTaskPdfDecorator < TaskPdfDecorator
  def decorate_pdf(pdf)
    super
    generate_peintre_details(pdf)
  end

  private

  def generate_peintre_details(pdf)
    taskable = @task.taskable
    pdf.move_down 20
    pdf.text "PAINTING SPECIFICATIONS", size: 16, style: :bold
    pdf.move_down 10

    # General Information
    pdf.text "General Information:", style: :bold
    pdf.text "- Type de Travaux: #{taskable.type_de_travaux}"
    pdf.text "- Type de Surface: #{taskable.type_de_surface}"
    pdf.text "- Nombre de Logements: #{taskable.nombre_de_logements}"
    pdf.text "- Nombre de Pièces: #{taskable.nombre_de_pieces}"

    # Measurements
    pdf.move_down 10
    pdf.text "Surface Areas:", style: :bold
    pdf.text "- Surface Sol: #{taskable.surface_sol} m²"
    pdf.text "- Surface Mur: #{taskable.surface_mur} m²"
    pdf.text "- Surface Plafond: #{taskable.surface_plafond} m²"

    pdf.move_down 10
    pdf.text "Required Services:", style: :bold

    services = [
      ["Peinture Lisse", :peinture_lisse],
      ["Gouttelette", :gouttelette],
      ["Gouttelette Écrasée", :gouttelette_ecrase],
      ["Pose Revêtement Tapisserie", :pose_revetement_tapisserie],
      ["Pose Revêtement Toile de Verre", :pose_revetement_toile_de_verre],
      ["Pose Revêtement Type Vescom", :pose_revetement_type_vescom],
      ["Pose Sol Sans Soudure", :pose_sol_sans_soudure],
      ["Pose Sol Avec Soudure à Chaux", :pose_sol_avec_soudure_a_chaux],
      ["Stuco Décoration", :stuco_decoration],
      ["Peinture Facade", :peinture_facade],
      ["Pose Plaques Type Decochoc", :pose_plaques_type_decochoc],
      ["Pose Plinthe", :pose_plinthe],
      ["Pose Parquet Flottant", :pose_parquet_fottant],
      ["Rattrapage Bande Placo", :rattrapage_bande_placo],
      ["Ratissage", :ratissage],
      ["Pose Baguette Angles", :pose_baguette_angles],
    ]

    services.each do |label, attribute|
      if taskable.send(attribute)
        pdf.text "- #{label}"
      end
    end

    # Other Tasks if present
    if taskable.other_task.present?
      pdf.move_down 10
      pdf.text "Additional Tasks:", style: :bold
      pdf.text taskable.other_task
    end
  end
end
