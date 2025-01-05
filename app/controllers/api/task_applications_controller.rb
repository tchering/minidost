class Api::TaskApplicationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :authenticate_user_from_token!
  before_action :set_task

  def index
    applications = @task.task_applications
    
    # Only show applications if user is the contractor or has applied
    unless @task.contractor_id == current_user.id || applications.exists?(subcontractor_id: current_user.id)
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    serialized_applications = applications.map do |app|
      {
        id: app.id,
        subcontractor_name: app.subcontractor.company_name,
        status: app.application_status,
        created_at: app.created_at.iso8601,
        proposed_price: app.proposed_price,
        notes: app.cover_letter
      }
    end

    render json: { applications: serialized_applications }
  end

  def create
    # Check if user already has an application
    if @task.task_applications.exists?(subcontractor_id: current_user.id)
      render json: { error: "Application already exists" }, status: :unprocessable_entity
      return
    end

    application = @task.task_applications.build(
      subcontractor_id: current_user.id,
      application_status: "pending",
      proposed_price: params[:proposed_price],
      cover_letter: params[:notes]
    )

    if application.save
      render json: {
        message: "Application submitted successfully",
        application: {
          id: application.id,
          status: application.application_status,
          created_at: application.created_at.iso8601
        }
      }, status: :created
    else
      render json: { error: application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    application = @task.task_applications.find_by(subcontractor_id: current_user.id)
    
    if application.nil?
      render json: { error: "Application not found" }, status: :not_found
      return
    end

    if application.destroy
      render json: { message: "Application withdrawn successfully" }
    else
      render json: { error: "Failed to withdraw application" }, status: :unprocessable_entity
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def authenticate_user_from_token!
    authorization = request.headers["Authorization"]

    if authorization.nil?
      render json: { error: "No token provided" }, status: :unauthorized and return
    end

    token = authorization.gsub(/^Bearer /, "").strip
    user = User.find_by(auth_token: token)

    if user
      @current_user = user
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
