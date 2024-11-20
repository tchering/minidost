class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number, :admin, companies_attributes: [:id, :legal_status, :company_name, :siret_number, :position, :activity_sector, :employees_number, :establishment_date, :turnover, :_destroy, addresses_attributes: [:id, :street, :city, :zip_code, :country, :_destroy]]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number, :admin, companies_attributes: [:id, :legal_status, :company_name, :siret_number, :position, :activity_sector, :employees_number, :establishment_date, :turnover, :_destroy, addresses_attributes: [:id, :street, :city, :zip_code, :country, :_destroy]]])
  end
end
