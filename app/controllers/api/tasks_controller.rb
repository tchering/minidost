module Api
  class TasksController < Api::BaseController
    before_action :authenticate_user_from_token!

    def index
      tasks = current_user.created_tasks
      active_tasks_applications_count = tasks.where(status: "active").sum { |t| t.task_applications.count }
      
      render json: {
        stats: {
          total_projects: tasks.count,
          pending: tasks.where(status: "pending").count,
          active: tasks.where(status: "active").count,
          in_progress: tasks.where(status: "in_progress").count,
          completed: tasks.where(status: "completed").count,
          conversations: current_user.conversations.count,
          active_applications: active_tasks_applications_count
        },
        tasks: tasks.map { |task|
          {
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            created_at: task.created_at,
            applications_count: task.task_applications.count
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
