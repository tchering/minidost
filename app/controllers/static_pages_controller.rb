# frozen_string_literal: true

class StaticPagesController < ApplicationController
  # show the home page without requiring authentication
  skip_before_action :authenticate_user!, only: %i[home contact blog help about]

  def home
    if user_signed_in?
      redirect_to user_path(current_user)
    end
  end

  def contact; end

  def blog; end

  def help; end

  def about; end
end
