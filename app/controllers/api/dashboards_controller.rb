module Api
  class DashboardsController < Api::BaseController
    def show
      user_info = {
        id: current_user.id,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        company_name: current_user.company_name,
        position: current_user.position,
        email: current_user.email,
        phone: current_user.phone_number,
        address: current_user.address,
        member_since: current_user.created_at.strftime("%B %d, %Y"),
        logo_url: current_user.logo.attached? ? url_for(current_user.logo) : nil
      }

      professional_info = {
        bio: current_user.bio&.text,
        activity_sector: current_user.activity_sector,
        establishment_date: current_user.establishment_date,
        employees_number: current_user.employees_number
      }

      tasks = current_user.position == "contractor" ? current_user.created_tasks : current_user.accepted_tasks
      active_tasks_applications_count = if current_user.position == "contractor"
        tasks.where(status: "active").sum { |t| t.task_applications.count }
      else
        0
      end

      render json: {
        user_info: user_info,
        professional_info: professional_info,
        stats: {
          total_projects: tasks.count,
          pending: tasks.where(status: "pending").count,
          active: tasks.where(status: "active").count,
          in_progress: tasks.where(status: "in progress").count,
          completed: tasks.where(status: "completed").count,
          conversations: current_user.conversations.count,
          active_applications: active_tasks_applications_count
        }
      }, status: :ok
    end
  end
end
