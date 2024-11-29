# frozen_string_literal: true

class BiosController < ApplicationController
  include ActionView::RecordIdentifier

  def show
    @bio = Bio.find(params[:id])
  end

  def new
    @bio = current_user.build_bio
  end

  def create
    @bio = current_user.build_bio(bio_params)
    respond_to do |format|
      if @bio.save
        format.html { redirect_to user_path(@bio.user), notice: 'Bio was successfully created' }
        format.json { render :show, status: :created, location: @bio }
      else
        format.html { render :new, status: :unprocessable_entity, notice: 'Bio was not created' }
        format.json { render json: @bio.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @bio = Bio.find(params[:id])
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'bio_form_frame',
          partial: 'bios/form',
          locals: { bio: @bio }
        )
      end
    end
  end

  def update
    @bio = Bio.find(params[:id])
    respond_to do |format|
      if @bio.update(bio_params)
        format.html { redirect_to user_path(@bio.user), notice: 'Bio was successfully updated' }
        format.json { render :show, status: :ok, location: @bio }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'bio_form_frame',
            partial: 'bios/bio',
            locals: { user: @bio.user, bio: @bio }
          )
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bio.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'bio_form_frame',
            partial: 'bios/form',
            locals: { bio: @bio }
          )
        end
      end
    end
  end

  private

  def bio_params
    params.require(:bio).permit(:text)
  end
end
