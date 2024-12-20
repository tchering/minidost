# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  # def after_sign_in_path_for(resource)
  #   user_path(resource)
  # end

  protected

  def configure_permitted_parameters
    # Add this before the permit call
    Rails.logger.debug "User errors: #{resource.errors.full_messages}" if resource&.errors&.any?

    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[first_name last_name phone_number admin position
                                               legal_status company_name siret_number activity_sector employees_number establishment_date turnover logo street city area_code country])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[first_name last_name phone_number admin position
                                               legal_status company_name siret_number activity_sector employees_number establishment_date turnover logo street city area_code country])
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
