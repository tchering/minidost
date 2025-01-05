class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_user_from_token!, only: [:create]

  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      render json: {
        token: user.auth_token,
        user: {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          company_name: user.company_name,
          position: user.position,
          main_sector: user.main_sector,
          sub_sector: user.sub_sector
        }
      }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    current_user&.regenerate_auth_token
    render json: { message: 'Successfully logged out' }
  end
end
