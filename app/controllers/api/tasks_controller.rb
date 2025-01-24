class Api::TasksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :authenticate_user_from_token!

  def index
    user = current_user
    status = params[:status]
    is_contractor = params[:is_contractor] == "true" || params[:position] == "contractor"

    Rails.logger.debug "TasksController#index - User: #{user.id}, Status: #{status}, IsContractor: #{is_contractor}"

    # For contractors
    if is_contractor
      tasks = user.created_tasks
      tasks = case status
        when "all"
          Rails.logger.debug "Fetching all tasks for contractor"
          tasks
        when "approved"
          Rails.logger.debug "Fetching approved tasks for contractor"
          # Get tasks that have approved status and approved applications
          tasks.where(status: "approved")
               .joins(:task_applications)
               .where(task_applications: { application_status: "approved" })
               .distinct
        when "pending"
          Rails.logger.debug "Fetching pending tasks for contractor"
          tasks.where(status: "pending")
        when "active"
          Rails.logger.debug "Fetching active tasks for contractor"
          tasks.where(status: "active")
        when "in_progress"
          Rails.logger.debug "Fetching in-progress tasks for contractor"
          tasks.where(status: "in_progress")
        when "completed"
          Rails.logger.debug "Fetching completed tasks for contractor"
          tasks.where(status: "completed")
        else
          Rails.logger.debug "Fetching tasks with status: #{status}"
          tasks.where(status: status)
        end
    else
      # For subcontractors, handle different application statuses
      tasks = case status
      when "pending"
        # Tasks where the subcontractor has pending applications
        Task.joins(:task_applications)
            .where(task_applications: { 
              subcontractor_id: user.id,
              application_status: "pending"
            })
      when "approved"
        # Tasks where the subcontractor's application was approved
        Task.joins(:task_applications)
            .where(task_applications: { 
              subcontractor_id: user.id,
              application_status: "approved"
            })
      when "rejected"
        # Tasks where the subcontractor's application was rejected
        Task.joins(:task_applications)
            .where(task_applications: { 
              subcontractor_id: user.id,
              application_status: "rejected"
            })
      when "completed"
        # Tasks that are marked as completed
        user.accepted_tasks.where(status: "completed")
      when "in_progress"
        # Tasks that are in progress
        user.accepted_tasks.where(status: "in_progress")
      else
        # Default to all tasks where the user has applied
        Task.joins(:task_applications)
            .where(task_applications: { subcontractor_id: user.id })
      end
    end

    Rails.logger.debug "Final SQL Query: #{tasks.to_sql}"
    Rails.logger.debug "Found #{tasks.count} tasks"

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
        
        # Add application details for subcontractors
        application_status: task.task_applications.find_by(subcontractor_id: user.id)&.application_status,
        my_application: task.task_applications.find_by(subcontractor_id: user.id).present?,
      }
    end

    render json: serialized_tasks
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def show
    task = Task.find(params[:id])
    Rails.logger.debug "Task details - contractor_id: #{task.contractor_id}, sub_contractor_id: #{task.sub_contractor_id}"
    Rails.logger.debug "Current user id: #{current_user.id}, position: #{current_user.position}"
    Rails.logger.debug "Has application?: #{task.task_applications.exists?(subcontractor_id: current_user.id)}"
    Rails.logger.debug "Task status: #{task.status}"

    # Ensure the user has permission to view this task
    authorized = task.contractor_id == current_user.id || # Contractor can always view
                 task.sub_contractor_id == current_user.id || # Assigned subcontractor can view
                 task.task_applications.exists?(subcontractor_id: current_user.id) || # Applied subcontractor can view
                 (["open", "active"].include?(task.status) && current_user.subcontractor?) # Subcontractors can view open and active tasks

    Rails.logger.debug "Authorization check: #{authorized}, is_subcontractor?: #{current_user.subcontractor?}"
    Rails.logger.debug "Status check: #{["open", "active"].include?(task.status)}"
    
    unless authorized
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    # Group taskable attributes
    taskable_attributes = task.taskable.attributes.except("id", "created_at", "updated_at")

    text_attributes = taskable_attributes.select { |_, v| v.is_a?(String) || v.is_a?(Numeric) }
    measurements = taskable_attributes.select { |k, _| k.include?("surface_") }
    boolean_services = taskable_attributes.select { |_, v| [true, false].include?(v) }

    # Get subcontractor details if assigned
    subcontractor_details = if task.sub_contractor
      {
        id: task.sub_contractor.id,
        company_name: task.sub_contractor.company_name,
        phone_number: task.sub_contractor.phone_number,
        email: task.sub_contractor.email,
        street: task.sub_contractor.street,
        city: task.sub_contractor.city,
        area_code: task.sub_contractor.area_code,
        position: task.sub_contractor.position,
        siret_number: task.sub_contractor.siret_number
      }
    end

    # Serialize task with comprehensive details
    task_details = {
      id: task.id,
      site_name: task.site_name,
      street: task.street,
      city: task.city,
      status: task.status,
      contractor_name: task.contractor.company_name,
      subcontractor: subcontractor_details,
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

  def available_tasks
    tasks = Task.where("LOWER(status) = ?", "active".downcase)
                .includes(contractor: { logo_attachment: :blob })

    if params[:query].present?
      tasks = tasks.search_by_term(params[:query])
    end

    serialized_tasks = tasks.map do |task|
      {
        id: task.id,
        site_name: task.site_name,
        taskable_type: task.taskable_type,
        taskable_id: task.taskable_id,
        status: task.status,
        city: task.city,
        street: task.street,
        start_date: task.start_date&.iso8601,
        end_date: task.end_date&.iso8601,
        proposed_price: task.proposed_price,
        work_progress: task.work_progress,
        contractor: {
          company_name: task.contractor.company_name,
          logo_url: task.contractor.logo.attached? ? url_for(task.contractor.logo) : nil
        }
      }
    end

    render json: { tasks: serialized_tasks }
  end

  private

  def authenticate_user_from_token!
    authorization = request.headers["Authorization"]
    Rails.logger.debug "Auth header: #{authorization}"

    if authorization.nil?
      render json: { error: "No token provided" }, status: :unauthorized and return
    end

    token = authorization.gsub(/^Bearer /, "").strip
    Rails.logger.debug "Extracted token: #{token}"
    
    user = User.find_by(auth_token: token)
    Rails.logger.debug "Found user: #{user&.id}"

    if user
      @current_user = user
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
