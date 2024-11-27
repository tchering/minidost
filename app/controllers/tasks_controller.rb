class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  def index
    @tasks = Task.all
  end

  def show
  end

  def new
    @task = current_user.tasks
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user])
  end
end
