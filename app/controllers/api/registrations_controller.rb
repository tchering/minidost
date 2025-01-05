class Api::RegistrationsController < Api::BaseController
  skip_before_action :authenticate_user_from_token!, only: [:create]

  def create
    # Map the incoming parameters to match the database fields
    mapped_params = user_params.dup
    mapped_params[:activity_sector] = mapped_params.delete(:main_sector) if mapped_params[:main_sector]
    mapped_params.delete(:sub_sector) # Remove sub_sector as it's not a database field

    # Set default values
    mapped_params[:country] = "France"

    # Convert position to lowercase for validation
    mapped_params[:position] = mapped_params[:position]&.downcase
    if mapped_params[:position] == "contractor"
      mapped_params[:position] = "contractor"
    elsif mapped_params[:position] == "sub-contractor"
      mapped_params[:position] = "sub-contractor"
    end

    user = User.new(mapped_params)

    if user.save
      render json: {
        status: "success",
        token: user.auth_token,
        user: {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          company_name: user.company_name,
          position: user.position,
          activity_sector: user.activity_sector,
          legal_status: user.legal_status,
          siret_number: user.siret_number,
          street: user.street,
          area_code: user.area_code,
          city: user.city,
          establishment_date: user.establishment_date,
          employees_number: user.employees_number,
        },
      }, status: :created
    else
      Rails.logger.info "User validation failed: #{user.errors.full_messages}"
      render json: {
        status: "error",
        errors: user.errors.full_messages,
      }, status: :unprocessable_entity
    end
  rescue ActionController::ParameterMissing => e
    Rails.logger.error "Parameter missing: #{e.message}"
    render json: {
      status: "error",
      errors: [e.message],
    }, status: :bad_request
  rescue => e
    Rails.logger.error "Registration error: #{e.class} - #{e.message}"
    render json: {
      status: "error",
      errors: [e.message],
    }, status: :internal_server_error
  end

  private

  def user_params
    params.require(:registration).require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :first_name,
      :last_name,
      :company_name,
      :legal_status,
      :position,
      :main_sector,  # Will be mapped to activity_sector
      :sub_sector,   # Will be ignored as it's not in the database
      :siret_number,
      :street,
      :area_code,
      :city,
      :establishment_date,
      :employees_number
    )
  end
end
