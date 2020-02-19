# frozen_string_literal: true

class TypesController < ApplicationController
  load_and_authorize_resource

  # GET /types
  # GET /types.json
  def index
    @types = Type.all
  end

  # GET /types/1
  # GET /types/1.json
  def show
  end

  # GET /types/new
  def new
    @type = Type.new
    @type.vocabulary_id = params[:vocabulary] if params[:vocabulary]
  end

  # GET /types/1/edit
  def edit
  end

  # POST /types
  # POST /types.json
  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @type = Type.new(type_params)

    respond_to do |format|
      if @type.save
        format.html do
          redirect_to @type.vocabulary,
                      notice: "#{t('activerecord.models.type')} #{@type.identifier} was successfully created."
        end
        format.json { render :show, status: :created, location: @type }
      else
        format.html { render :new }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /types/1
  # PATCH/PUT /types/1.json
  def update
    respond_to do |format|
      if @type.update(type_params)
        format.html { redirect_to @type, notice: "#{t('activerecord.models.type')} was successfully updated." }
        format.json { render :show, status: :ok, location: @type }
      else
        format.html { render :edit }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /types/1
  # DELETE /types/1.json
  def destroy
    @type.destroy
    respond_to do |format|
      format.html { redirect_to types_url, notice: "#{t('activerecord.models.type')} was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def type_params
      params.require(:type).permit(:identifier, :vocabulary_id)
    end
end
