class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.position == "contractor"
      @tasks = current_user.created_tasks
    elsif current_user.position == "subcontractor"
      @tasks = current_user.accepted_tasks
    else
      @tasks = Task.all
    end
  end

  def show
  end

  def activity_to_taskable_type(activity)
    return nil if activity.nil?

    # Convert activity name to model name format
    activity.gsub(/[^\w\s]/, "") # Remove special characters
      .split # Split into words
      .map(&:capitalize) # Capitalize each word
      .join # Join words together
      .concat("Task") # Add 'Task' suffix
  end

  # "Charpentier bois"
  # .gsub(/[^\w\s]/, "") # -> "Charpentier bois"
  # .split               # -> ["Charpentier", "bois"]
  # .map(&:capitalize)   # -> ["Charpentier", "Bois"]
  # .join               # -> "CharpentierBois"
  # .concat("Task")     # -> "CharpentierBoisTask"

  def new
    # Remove these lines:
    # activity = params[:activity]
    # @taskable_type = activity_to_taskable_type(activity)

    # Keep this but without taskable_type:
    @task = current_user.created_tasks.build

    # Remove this line - taskable will be handled by load_taskable_fields:
    # @task.taskable = @taskable_type
  end

  def create
    @task = current_user.created_tasks.build(task_params)
    @taskable_type = params[:task][:taskable_type]
    @task.taskable = @taskable_type.constantize.new(taskable_params.to_h)
    # @task.contractor = current_user
    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: "Task was successfully created" }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity, notice: "Task was not created" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def load_taskable_fields
    @taskable_type = params[:taskable_type] #received from stimulus controller
    @task = Task.new(taskable_type: @taskable_type)
    @task.taskable = @taskable_type.constantize.new

    respond_to do |format|
      format.html do
        render partial: "tasks/form_#{@taskable_type.underscore}",
               locals: { task: @task },
               layout: false
      end
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    common_fields = [:taskable_type, :sub_contractor_id, :site_name, :street, :city, :area_code, :proposed_price, :accepted_price, :start_date, :end_date, :status, :work_progress, :billing_process]
    params.require(:task).permit(common_fields, taskable_attributes: taskable_params)
  end

  def taskable_params
    case params[:task][:taskable_type]
    when "PeintreTask"
      params.require(:taskable).permit(
        :type_de_travaux,
        :type_de_surface,
        :nombre_de_logements,
        :nombre_de_pieces,
        :surface_sol,
        :surface_mur,
        :surface_plafond,
        :peinture_lisse,
        :gouttelette,
        :gouttelette_ecrase,
        :pose_revetement_tapisserie,
        :pose_revetement_toile_de_verre,
        :pose_revetement_type_vescom,
        :pose_sol_sans_soudure,
        :pose_sol_avec_soudure_a_chaux,
        :stuco_decoration,
        :peinture_facade,
        :pose_plaques_type_decochoc,
        :pose_faience,
        :pose_petite_platrerie,
        :pose_plinthe,
        :pose_parquet_fottant,
        :rattrapage_bande_placo,
        :ratissage,
        :pose_baguette_angles,
        :other_task
      )
    else
      {}
    end
  end
end
