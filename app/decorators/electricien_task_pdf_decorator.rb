#! -->2 app/decorators/electricien_task_pdf_decorator.rb
class ElectricienTaskPdfDecorator < TaskPdfDecorator
  def decorate_pdf(pdf)
    super
    generate_electricien_details(pdf)
  end

  private

  def generate_electricien_details(pdf)
    taskable = @task.taskable
    pdf.move_down 20
    pdf.text "ELECTRICAL SPECIFICATIONS", size: 16, style: :bold
    pdf.move_down 10

    # General Information
    pdf.text "General Details:", style: :bold
    pdf.text "- Type de Travaux: #{taskable.type_de_travaux}"
    pdf.text "- Type de batiment: #{taskable.type_de_batiment}"
    pdf.text "- Nombre de Pièces: #{taskable.nombre_de_pieces}"

    # Technical Information
    pdf.move_down 10
    pdf.text "Technical Details:", style: :bold
    pdf.text "- Ampérage Principal: #{taskable.amperage_principal}"
    pdf.text "- Tension Requise: #{taskable.tension_requise}"
    pdf.text "- Type de Phase: #{taskable.phase_type}"

    pdf.move_down 10
    pdf.text "Required Services:", style: :bold

    services = [
      ["Installation Tableau Électrique", :installation_tableau_electrique],
      ["Mise aux Normes Tableau", :mise_aux_normes_tableau],
      ["Pose Prises Électriques", :pose_prises_electriques],
      ["Pose Interrupteurs", :pose_interrupteurs],
      ["Installation Éclairage", :installation_eclairage],
      ["Pose Luminaires", :pose_luminaires],
      ["Installation Cuisine", :installation_cuisine],
      ["Installation Salle de Bain", :installation_salle_de_bain],
      ["Installation Extérieure", :installation_exterieure],
      ["Installation Cave/Garage", :installation_cave_garage],
      ["Mise à la Terre", :mise_a_la_terre],
      ["Installation Différentiel", :installation_differentiel],
      ["Installation Parafoudre", :installation_parafoudre],
      ["Vérification Conformité", :verification_conformite],
      ["Installation Domotique", :installation_domotique],
      ["Installation Vidéophone", :installation_videophone],
      ["Installation Alarme", :installation_alarme],
      ["Installation Ventilation", :installation_ventilation],
      ["Dépannage Urgent", :depannage_urgent],
      ["Recherche Panne", :recherche_panne],
      ["Modification Existant", :modification_existant],
      ["Passage Câbles", :passage_cables],
      ["Saignée Murs", :saignee_murs],
    ]

    services.each do |label, attribute|
      if taskable.send(attribute)
        pdf.text "- #{label}"
      end
    end

    # Technical Specifications if present
    if taskable.respond_to?(:specifications_techniques)
      pdf.move_down 10
      pdf.text "Technical Specifications:", style: :bold
      pdf.text taskable.specifications_techniques
    end

    # Other Tasks if present
    if taskable.other_task.present?
      pdf.move_down 10
      pdf.text "Additional Tasks:", style: :bold
      pdf.text taskable.other_task
    end
  end
end
