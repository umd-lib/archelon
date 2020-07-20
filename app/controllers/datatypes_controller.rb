# frozen_string_literal: true

class DatatypesController < ApplicationController
  load_and_authorize_resource

  # GET /datatypes
  # GET /datatypes.json
  def index
    @datatypes = Datatype.all
  end

  # GET /datatypes/1
  # GET /datatypes/1.json
  def show
  end

  # GET /datatypes/new
  def new
    @datatype = Datatype.new
    @datatype.vocabulary_id = params[:vocabulary] if params[:vocabulary]
  end

  # GET /datatypes/1/edit
  def edit
  end

  # POST /datatypes
  # POST /datatypes.json
  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @datatype = Datatype.new(datatype_params)

    respond_to do |format|
      if @datatype.save
        format.html do
          redirect_to @datatype.vocabulary,
                      notice: "#{t('activerecord.models.datatype')} #{@datatype.identifier} was successfully created."
        end
        format.json { render :show, status: :created, location: @datatype }
      else
        format.html { render :new }
        format.json { render json: @datatype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /datatypes/1
  # PATCH/PUT /datatypes/1.json
  def update
    respond_to do |format|
      if @datatype.update(datatype_params)
        format.html { redirect_to @datatype, notice: "#{t('activerecord.models.datatype')} was successfully updated." }
        format.json { render :show, status: :ok, location: @datatype }
      else
        format.html { render :edit }
        format.json { render json: @datatype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datatypes/1
  # DELETE /datatypes/1.json
  def destroy
    @datatype.destroy
    respond_to do |format|
      format.html do
        redirect_to datatypes_url,
                    notice: "#{t('activerecord.models.datatype')} was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def datatype_params
      params.require(:datatype).permit(:identifier, :vocabulary_id)
    end
end
