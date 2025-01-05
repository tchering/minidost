class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_user_from_token!, only: [:create]

  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      token = user.ensure_authentication_token!
      
      if token
        render json: {
          token: token,
          user: {
            id: user.id,
            email: user.email || "",
            first_name: user.first_name || "",
            last_name: user.last_name || "",
            company_name: user.company_name || "",
            position: user.position || "",
            activity_sector: user.activity_sector || "",
            legal_status: user.legal_status || "",
            siret_number: user.siret_number || "",
            street: user.street || "",
            area_code: user.area_code || "",
            city: user.city || "",
            establishment_date: user.establishment_date || 0,
            employees_number: user.employees_number || 0
          }
        }
      else
        render json: { error: 'Failed to generate authentication token' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  rescue => e
    Rails.logger.error("Login error: #{e.message}")
    render json: { error: 'Authentication failed' }, status: :unprocessable_entity
  end

  def destroy
    current_user&.update_column(:auth_token, nil)
    render json: { message: 'Successfully logged out' }
  end
end
