module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user_from_token!, except: [:create]
  end

  private

  def authenticate_user_from_token!
    return true if controller_name == 'registrations' && action_name == 'create'
    
    auth_token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized unless auth_token

    @current_user = User.find_by_auth_token(auth_token)
    render_unauthorized unless @current_user
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
