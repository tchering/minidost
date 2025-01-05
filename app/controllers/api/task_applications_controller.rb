class Api::TaskApplicationsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!
  before_action :set_task
  before_action :set_task_application, only: [:show, :update, :destroy]

  def index
    @applications = @task.task_applications.includes(:subcontractor)
    render json: @applications.map { |app| application_json(app) }
  end

  def show
    render json: application_json(@task_application)
  end

  def show_my_application
    @application = @task.task_applications.find_by(subcontractor: current_user)
    if @application
      render json: application_json(@application)
    else
      render json: { error: 'Application not found' }, status: :not_found
    end
  end

  def create
    @application = @task.task_applications.build(task_application_params)
    @application.subcontractor = current_user
    @application.application_status = 'pending'

    if @application.save
      render json: application_json(@application), status: :created
    else
      render json: { errors: @application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @task_application.update(task_application_params)
      render json: application_json(@task_application)
    else
      render json: { errors: @task_application.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @task_application.destroy
    head :no_content
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def set_task_application
    @task_application = @task.task_applications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Application not found" }, status: :not_found
  end

  def task_application_params
    params.require(:task_application).permit(:proposed_price, :application_status, :cover_letter, :experience, :completion_timeframe, :insurance_status, :skills, :equipment_owned, :payment_terms, :references, :negotiable)
  end

  def application_json(application)
    {
      id: application.id,
      task_id: application.task_id,
      subcontractor_id: application.subcontractor_id,
      subcontractor_name: application.subcontractor.company_name,
      proposed_price: application.proposed_price,
      status: application.application_status,
      created_at: application.created_at,
      updated_at: application.updated_at
    }
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

  def current_user
    @current_user
  end
end
