# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]
  helper_method :group_attributes
  include TasksHelper

  def index
    @tasks = if current_user.position == "contractor"
        tasks = current_user.created_tasks
          .includes(:contractor, :sub_contractor, :contract)
        if params[:has_applications] == "true"
          tasks = tasks.joins(:task_applications).distinct
        end
        tasks
      elsif current_user.position == "sub-contractor"
        current_user.accepted_tasks
          .includes(:contractor, :sub_contractor, :contract)
      else
        Task.includes(:contractor, :sub_contractor, :contract).all
      end
    # Filter by status if provided
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?

    #preload task applications to avoid N+1 queries
    # @tasks = @tasks.includes(:task_applications)
    # Create a hash mapping task_id to application count and passed to index.html.erb
    @task_application_counts = TaskApplication
      .where(task_id: @tasks.pluck(:id))
      .group(:task_id)
      .count || {}

    respond_to do |format|
      format.html { }
      format.turbo_stream do
      end
    end
  end

  def application_list
    @task = Task.find(params[:id])
    @applications = @task.task_applications
      .includes(subcontractor: { logo_attachment: :blob })
      .order(created_at: :desc)
  end

  def show; end

  def activity_to_taskable_type(activity)
    return nil if activity.nil?

    #! Convert activity name to model name format but we dont need this here becuase it is handled in the form with this line-> [activity, "#{activity.parameterize.classify}Task"]
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

    if @taskable_type.present?
      @task.taskable = @taskable_type.constantize.new(taskable_params.to_h)
    else
      @task.errors.add(:base, t("task.select_activity"))
      # @task.errors.add(:taskable_type, "Activity must be selected")
      render :new, status: :unprocessable_entity
      return
    end

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
    @task = Task.find(params[:id])
    attributes = @task.taskable.attributes.except("id", "created_at", "updated_at")
    @grouped_attributes = group_attributes(@task.taskable, attributes)
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      @task.taskable.update(taskable_params)
      redirect_to @task, notice: "Task successfully updated"
    else
      attributes = @task.taskable.attributes.except("id", "created_at", "updated_at")
      @grouped_attributes = group_attributes(@task.taskable, attributes)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    respond_to do |format|
      if @task.destroy
        format.html { redirect_to user_path(current_user), notice: "Task was successfully destroyed" }
        format.json { head :no_content }
      else
        format.html { redirect_to tasks_url, alert: "Task could not be destroyed", status: :unprocessable_entity }
        format.json { }
      end
    end
  end

  def load_taskable_fields
    @taskable_type = params[:taskable_type]

    respond_to do |format|
      format.html do
        render partial: "tasks/form_#{@taskable_type.underscore}",
               layout: false
      end
    end
  end

  def available_tasks
    @tasks = Task.where("LOWER(status) = ?", "active".downcase)
                 .includes(contractor: { logo_attachment: :blob })

    if params[:query].present?
      @tasks = @tasks.search_by_term(params[:query])
    end

    respond_to do |format|
      format.html
      format.turbo_stream {
        render turbo_stream: turbo_stream.update("tasks-list",
                                                 partial: "tasks/tasks_list",
                                                 locals: { tasks: @tasks })
      }
    end
  end

  def express_interest
    # @task = Task.find(params[:id]) # This is already done in before_action
    if @task.task_applications.exists?(sub_contractor: current_user)
      flash[:notice] = t("task.already_interested_message")
    else
      application = @task.task_applications.build(application_params)
    end
  end

  # def delete_interest
  #   # @task = Task.find(params[:id]) # This is already done in before_action
  #   if @task.sub_contractor_list.include?(current_user.id)
  #     @task.delete_interested_subcontractor(current_user.id)
  #     flash[:notice] = t("task.not_interested_message")
  #   end
  #   redirect_to task_path(@task)
  # end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    common_fields = %i[taskable_type sub_contractor_id site_name street city area_code proposed_price
                       accepted_price start_date end_date status work_progress billing_process]
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
    when "ElectricienTask"
      params.require(:taskable).permit(
        # String fields
        :type_de_travaux,
        :type_de_batiment,
        :nombre_de_pieces,
        :surface_totale,
        :amperage_principal,
        :tension_requise,
        :phase_type,

        # Boolean fields
        :installation_tableau_electrique,
        :mise_aux_normes_tableau,
        :pose_prises_electriques,
        :pose_interrupteurs,
        :installation_eclairage,
        :pose_luminaires,
        :installation_cuisine,
        :installation_salle_de_bain,
        :installation_exterieure,
        :installation_cave_garage,
        :mise_a_la_terre,
        :installation_differentiel,
        :installation_parafoudre,
        :verification_conformite,
        :installation_domotique,
        :installation_videophone,
        :installation_alarme,
        :installation_ventilation,
        :depannage_urgent,
        :recherche_panne,
        :modification_existant,
        :passage_cables,
        :saignee_murs,

        # Text field
        :other_task
      )
    else
      {}
    end
  end
end
