#responsible for rendering the attributes of a taskable object
module TasksHelper
  def render_taskable_attributes(taskable)
    return unless taskable

    # Get all attributes except timestamps and ids
    attributes = taskable.attributes.except(
      "id", "created_at", "updated_at"
    )

    # Group attributes by type
    groups = group_attributes(taskable, attributes)

    render partial: "tasks/taskable_attributes",
           locals: { groups: groups, taskable: taskable }
  end

  def status_color(status)
    case status&.downcase
    when "pending" then "warning"
    when "in progress" then "info"
    when "completed" then "success"
    else "secondary"
    end
  end

  def task_type_icon(taskable_type)
    case taskable_type
    when "PeintreTask"
      "fas fa-paint-roller"
    when "PlombierTask"
      "fas fa-wrench"
    when "ElectricienTask"
      "fas fa-bolt"
    when "CharpentierBoisTask"
      "fas fa-hammer"
    when "CouvreurTask"
      "fas fa-home"
    when "MaconTask"
      "fas fa-hard-hat"
    when "CarreleurTask"
      "fas fa-th-large"
    when "MenuisierTask"
      "fas fa-door-open"
    else
      "fas fa-tools"  # Default icon
    end
  end

  private

  def group_attributes(taskable, attributes)
    {
      text_attributes: attributes.select { |_, v| v.is_a?(String) },
      measurements: attributes.select { |k, _| k.include?("surface_") },
      boolean_services: attributes.select { |_, v| [true, false].include?(v) },
    }
  end
end
