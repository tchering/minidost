module Api
  class UsersController < Api::BaseController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user_from_token!

    def show
      tasks = current_user.created_tasks
      active_tasks_applications_count = tasks.where(status: "active").sum { |t| t.task_applications.count }

      render json: {
        user: {
          id: current_user.id,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          email: current_user.email,
          company_name: current_user.company_name,
          position: current_user.position,
          logo_url: current_user.logo.attached? ? url_for(current_user.logo) : nil,
          created_at: current_user.created_at,
          street: current_user.street,
          area_code: current_user.area_code,
          city: current_user.city,
          siret_number: current_user.siret_number,
          main_sector: current_user.main_sector,
          sub_sector: current_user.sub_sector,
          stats: {
            total_projects: tasks.count,
            pending: tasks.where(status: "pending").count,
            active: tasks.where(status: "active").count,
            in_progress: tasks.where(status: "in_progress").count,
            completed: tasks.where(status: "completed").count,
            conversations: current_user.conversations.count,
            active_applications: active_tasks_applications_count
          }
        }
      }, status: :ok, content_type: 'application/json'
    end

    private

    def authenticate_user_from_token!
      token = request.headers['Authorization']
      return render json: { error: 'No token provided' }, status: :unauthorized, content_type: 'application/json' unless token

      user = User.find_by(authentication_token: token)
      if user
        sign_in(user)
      else
        render json: { error: 'Invalid token' }, status: :unauthorized, content_type: 'application/json'
      end
    end
  end
end
