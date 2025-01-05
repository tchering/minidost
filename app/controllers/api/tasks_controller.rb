class Api::TasksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :authenticate_user_from_token!

  def index
    user = current_user
    status = params[:status]
    is_contractor = params[:is_contractor] == "true"

    # Determine the base query based on user type and contractor flag
    if is_contractor
      tasks = user.created_tasks
    else
      tasks = user.accepted_tasks
    end

    # Handle different status filtering
    tasks = case status
      when "all"
        tasks
      when "approved"
        tasks.joins(:task_applications)
             .where(task_applications: { application_status: "approved" })
             .distinct
      else
        tasks.where(status: status)
      end

    # Serialize tasks with available information
    serialized_tasks = tasks.map do |task|
      {
        id: task.id,
        site_name: task.site_name,
        street: task.street,
        city: task.city,
        status: task.status,
        contractor_name: task.contractor.company_name,
        subcontractor_name: task.sub_contractor&.company_name,
        created_at: task.created_at.iso8601,
        proposed_price: task.proposed_price,
        accepted_price: task.accepted_price,
        start_date: task.start_date&.iso8601,
        end_date: task.end_date&.iso8601,
        work_progress: task.work_progress,
        billing_process: task.billing_process,
        applications_count: task.task_applications.count,
      }
    end

    render json: serialized_tasks
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    task = Task.find(params[:id])

    # Ensure the user has permission to view this task
    unless task.contractor_id == current_user.id || task.sub_contractor_id == current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    # Group taskable attributes
    taskable_attributes = task.taskable.attributes.except("id", "created_at", "updated_at")

    text_attributes = taskable_attributes.select { |_, v| v.is_a?(String) || v.is_a?(Numeric) }
    measurements = taskable_attributes.select { |k, _| k.include?("surface_") }
    boolean_services = taskable_attributes.select { |_, v| [true, false].include?(v) }

    # Serialize task with comprehensive details
    task_details = {
      id: task.id,
      site_name: task.site_name,
      street: task.street,
      city: task.city,
      status: task.status,
      contractor_name: task.contractor.company_name,
      subcontractor_name: task.sub_contractor&.company_name,
      created_at: task.created_at.iso8601,
      proposed_price: task.proposed_price,
      accepted_price: task.accepted_price,
      start_date: task.start_date&.iso8601,
      end_date: task.end_date&.iso8601,
      work_progress: task.work_progress,
      billing_process: task.billing_process,
      applications_count: task.task_applications.count,

      # Additional details
      contractor_id: task.contractor_id,
      sub_contractor_id: task.sub_contractor_id,
      taskable_type: task.taskable_type,

      # Pre-grouped taskable details
      text_attributes: text_attributes,
      measurements: measurements,
      boolean_services: boolean_services,
    }

    render json: task_details
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate_user_from_token!
    authorization = request.headers["Authorization"]

    if authorization.nil?
      render json: { error: "No token provided" }, status: :unauthorized and return
    end

    token = authorization.gsub(/^Bearer /, "")
    user = User.find_by(auth_token: token)

    if user
      @current_user = user
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
