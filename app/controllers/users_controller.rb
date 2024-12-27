# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def index
    @users = User.all.includes(logo_attachment: :blob)
  end

  def show
    # you can get task IDs for a user through their associations.
    # We need to get task becuase we are using route task_task_applications GET  (/:locale)/tasks/:task_id/task_applications(.:format)
    # we will pass @task to show.html.erb and then to _task_status_subcontractor.html.erb
    #! Option 1: If you want tasks from pending applications
    # Get first pending application's task
    @task = @user.task_applications
      .includes(:task)
      .find_by(application_status: "pending")
      &.task

    # Eager load notifications with their notifiable records and associations
    @notifications = @user.notifications
      .includes(
        :recipient,
        notifiable: [
          :conversation,  # For Message notifications
          :sender,        # For Message notifications
          :task,         # For TaskApplication and Contract notifications
          :user          # For Contract notifications
        ]
      )
      .order(created_at: :desc)
      .limit(10)

    #! @active_tasks_applications_count is passed to view _task_status.html.erb
    @active_tasks_applications_count = TaskApplication
      .joins(:task) # Joins TaskApplication with Task table
      .where(tasks: { # Filters tasks where:
               contractor_id: @user.id,               # - Task belongs to current contractor
               status: "active",                       # - Task status is active
             })
      .count                                   # Counts total applications

    # Add this to calculate unsigned contracts
    @unsigned_contracts_count = if @user.subcontractor?
      @user.task_applications
        .approved
        .joins(task: :contract)
        .where.not(tasks: { contract: nil })
        .where('contracts.signed_by_subcontractor IS NULL OR contracts.signed_by_subcontractor = ?', false)
        .count
    else
      0
    end
  end

  def show_map
    @user = User.find(params[:id])
    @markers = if @user.contractor?
        # Get all tasks created by the contractor that have coordinates
        @user.created_tasks
             .includes(:sub_contractor, :contractor, :task_applications)
             .where.not(latitude: nil, longitude: nil)
             .map { |task| create_task_marker(task) }
      elsif @user.subcontractor?
        # Get all tasks accepted by the subcontractor that have coordinates
        @user.accepted_tasks
          .where.not(latitude: nil, longitude: nil)
          .map { |task| create_task_marker(task) }
      else
        [] # Empty for non-contractors
      end
    render partial: "users/map", locals: { markers: @markers, user: @user }
  end

  private

  def set_user
    # यो method before_action ले show भन्दा अगाडि call गर्छ
    # सुनिश्चित गर्छ कि @user set गरिएको छ कुनै action को लागि जसलाई यसको आवश्यकता छ
    @user = User.find(params[:id])
  end

  def create_task_marker(task)
    {
      lat: task.latitude,
      lng: task.longitude,
      status: task.status,
      info_window_html: render_to_string(
        partial: "tasks/task_popup",
        locals: {
          task: task,
          subcontractor: task.sub_contractor,
        },
      ),
      image_url: if task.contractor.logo.attached?
        rails_blob_url(task.contractor.logo)
      else
        helpers.asset_url("default_logo.png")
      end,
    }
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
