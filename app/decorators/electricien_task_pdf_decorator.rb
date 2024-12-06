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
    pdf.text "- Nombre de Logements: #{taskable.nombre_de_logements}"
    pdf.text "- Nombre de Pièces: #{taskable.nombre_de_pieces}"

    pdf.move_down 10
    pdf.text "Required Services:", style: :bold

    services = [
      ["Installation Tableau Principal", :installation_tableau_principal],
      ["Installation Tableau Divisionnaire", :installation_tableau_divisionnaire],
      ["Mise aux Normes Installation", :mise_aux_normes_installation],
      ["Installation Prises de Courant", :installation_prises_courant],
      ["Installation Points Lumineux", :installation_points_lumineux],
      ["Installation Interrupteurs", :installation_interrupteurs],
      ["Installation VMC", :installation_vmc],
      ["Installation Chauffage Electrique", :installation_chauffage_electrique],
      ["Installation Radiateurs", :installation_radiateurs],
      ["Installation Convecteurs", :installation_convecteurs],
      ["Installation Climatisation", :installation_climatisation],
      ["Installation Prise Force", :installation_prise_force],
      ["Installation Prise Triphasée", :installation_prise_triphasee],
      ["Installation Bandeau LED", :installation_bandeau_led],
      ["Installation Spot LED", :installation_spot_led],
      ["Installation Détecteur Présence", :installation_detecteur_presence],
      ["Installation Vidéophone", :installation_videophone],
      ["Installation Portail Electrique", :installation_portail_electrique],
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
