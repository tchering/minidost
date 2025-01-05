# frozen_string_literal: true

class Api::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :authenticate_user_from_token!

  def profile
    # Prepare user details for the mobile app
    user_details = {
      id: current_user.id,
      email: current_user.email,
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      company_name: current_user.company_name,
      position: current_user.position,
      phone: current_user.phone_number,
      address: "#{current_user.street}, #{current_user.area_code} #{current_user.city}, #{current_user.country}",
      created_at: current_user.created_at.iso8601,
      logo_url: current_user.logo.attached? ? rails_blob_url(current_user.logo) : nil,
    }

    render json: user_details
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def authenticate_user_from_token!
    # Extract the token from the Authorization header
    authorization = request.headers["Authorization"]

    if authorization.nil?
      render json: { error: "No token provided" }, status: :unauthorized and return
    end

    # Remove 'Bearer ' prefix if present
    token = authorization.gsub(/^Bearer /, "")

    # Find the user by the auth_token
    user = User.find_by(auth_token: token)

    if user
      # Manually set the current user
      @current_user = user
    else
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
