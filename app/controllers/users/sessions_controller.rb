class Users::SessionsController < Devise::SessionsController
  # def after_sign_in_path_for(resource)
  #   about_path
  # end
end

# Sessions Controller: Only affects sign-in redirects
#
#if i put this in application controller
# Application Controller: Affects all Devise redirects (sign in, sign up, etc.)
