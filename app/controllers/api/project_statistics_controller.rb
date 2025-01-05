# frozen_string_literal: true

class Api::ProjectStatisticsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :authenticate_user_from_token!

  def index
    user = current_user

    if user.contractor?
      statistics = fetch_contractor_statistics(user)
    elsif user.subcontractor?
      statistics = fetch_subcontractor_statistics(user)
    else
      render json: { error: "Invalid user type" }, status: :unprocessable_entity
      return
    end

    render json: statistics
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

  def fetch_contractor_statistics(user)
    # Tasks by status
    total_projects = user.created_tasks.count
    pending_projects = user.created_tasks.where(status: "pending").count
    active_projects = user.created_tasks.where(status: "active").count
    in_progress_projects = user.created_tasks.where(status: "in_progress").count
    completed_projects = user.created_tasks.where(status: "completed").count

    # Get approved applications count (tasks must be approved and applications must be approved)
    approved_applications = TaskApplication.joins(:task)
      .where(
        tasks: { 
          contractor_id: user.id,
          status: "approved"
        }, 
        application_status: "approved"
      ).count

    # Get tasks that need contracts
    tasks_without_contracts = Task.joins(:task_applications)
      .where(
        contractor_id: user.id,
        status: "approved",
        task_applications: { application_status: "approved" }
      )
      .left_joins(:contract)
      .where(contracts: { id: nil })
      .count

    # Active tasks applications count
    active_tasks_applications = TaskApplication
      .joins(:task)
      .where(
        tasks: { 
          contractor_id: user.id, 
          status: "active"
        },
        application_status: "pending"
      ).count

    {
      total_projects: total_projects,
      pending_projects: pending_projects,
      active_projects: active_projects,
      in_progress_projects: in_progress_projects,
      completed_projects: completed_projects,
      approved_applications: approved_applications,
      tasks_without_contracts: tasks_without_contracts,
      active_tasks_applications_count: active_tasks_applications,
      conversations_count: user.conversations.count,
      total_unread_messages_count: total_unread_messages_count(user)
    }
  end

  def fetch_subcontractor_statistics(user)
    {
      # Application statistics
      total_applications: user.task_applications.count,
      approved_applications: user.task_applications.where(application_status: "approved").count,
      pending_applications: user.task_applications.where(application_status: "pending").count,
      rejected_applications: user.task_applications.where(application_status: "rejected").count,

      # Project status
      in_progress_projects: user.accepted_tasks.where(status: "in progress").count,
      completed_projects: user.accepted_tasks.where(status: "completed").count,

      # Conversations and messages
      conversations_count: user.conversations.count,
      total_unread_messages_count: total_unread_messages_count(user),
    }
  end

  def total_unread_messages_count(user)
    Message.joins(:conversation)
      .where(conversations: { sender_id: user.id })
      .or(Message.joins(:conversation).where(conversations: { recipient_id: user.id }))
      .where(read: false)
      .where.not(sender_id: user.id)
      .count
  end
end
