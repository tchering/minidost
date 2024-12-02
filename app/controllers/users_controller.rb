# frozen_string_literal: true
require "pry"

class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
    # you can get task IDs for a user through their associations.
    # We need to get task becuase we are using route task_task_applications GET  (/:locale)/tasks/:task_id/task_applications(.:format)
    # we will pass @task to show.html.erb and then to _task_status_subcontractor.html.erb
    @tasks = @user.applied_tasks
    # Use find instead of each to get the first task with a pending application
    @task = @tasks.find do |task|
      task.task_applications.find_by(subcontractor: current_user)
    end

    @user = User.find(params[:id])
    # @active_tasks_applications_count is passed to view _task_status.html.erb
    @active_tasks_applications_count = TaskApplication
      .joins(:task) # Joins TaskApplication with Task table
      .where(tasks: { # Filters tasks where:
               contractor_id: @user.id,               # - Task belongs to current contractor
               status: "active",                       # - Task status is active
             })
      .count                                   # Counts total applications
  end

  def show_map
    @user = User.find(params[:id])
    @markers = case @user.position
      when "Donneur-d'ordre"
        # 4a. यदि contractor ले आफ्नो profile हेर्दै छ भने:
        # - Database का सबै subcontractors खोज्नुहोस्
        # - .geocoded ले सुनिश्चित गर्छ valid lat/long भएका users मात्रै आउँछ
        # - .map ले प्रत्येक subcontractor लाई marker मा बदल्छ
        User.where(position: "Sous-traitant").geocoded.map do |user|
          create_marker(user)
        end
      when "Sous-traitant"
        # 4b. यदि subcontractor ले आफ्नो profile हेर्दै छ भने:
        # - सबै contractors खोज्नुहोस्
        # - उस्तै process: geocoded users पाउनुहोस् र markers बनाउनुहोस्
        User.where(position: "Donneur-d'ordre").includes(:logo_attachment).geocoded.map do |user|
          create_marker(user)
        end
      else
        # ! 4c. यदि position invalid छ भने, खाली array फिर्ता गर्नुहोस् (कुनै marker हुँदैन)
        []
      end
    render partial: "users/map", locals: { markers: @markers, user: @user }
  end

  private

  def set_user
    # यो method before_action ले show भन्दा अगाडि call गर्छ
    # सुनिश्चित गर्छ कि @user set गरिएको छ कुनै action को लागि जसलाई यसको आवश्यकता छ
    @user = User.find(params[:id])
  end

  def create_marker(user)
    # Hash बनाउनुहोस् जसलाई Mapbox JS ले markers राख्न प्रयोग गर्छ
    {
      # Geocoder gem ले user को coordinates पाएको छ:
      # - जब user ले address थप्छ/अपडेट गर्छ, geocoder ले त्यसलाई lat/long मा बदल्छ
      # - यी user.latitude र user.longitude मा store गरिन्छ
      lat: user.latitude,
      lng: user.longitude,

      # Popup window को HTML बनाउनुहोस्:
      # 1. render_to_string ले Rails partial लाई HTML string मा convert गर्छ
      # 2. _user_popup.html.erb ले popup को design राख्छ
      # 3. locals: {user: user} ले user को data partial मा pass गर्छ
      # 4. Result HTML हो जुन Mapbox ले popup मा देखाउनेछ
      info_window_html: render_to_string(
        partial: "users/user_popup",
        locals: { user: user },
      ),

      # Marker image set गर्नुहोस्:
      # 1. जाँच गर्नुहोस् कि user ले logo upload गरेको छ कि छैन (user.logo.attached?)
      # 2. यदि हो भने: uploaded logo को URL generate गर्नुहोस् (rails_blob_url)
      # 3. यदि छैन भने: default logo image प्रयोग गर्नुहोस् (helpers.asset_url)
      # यो URL Mapbox ले custom marker icon देखाउन प्रयोग गर्नेछ
      image_url: if user.logo.attached?
        rails_blob_url(user.logo)
      else
        helpers.asset_url("default_logo.png")
      end,
    }
  end
end
