
class Users::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path(locale: I18n.locale)
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path(locale: I18n.locale)
  end
end
