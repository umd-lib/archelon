# frozen_string_literal: true

class VocabulariesController < ApplicationController
  before_action :set_vocabulary, only: %i[show edit update destroy]

  # GET /vocabularies
  # GET /vocabularies.json
  def index
    @vocabularies = Vocabulary.all
  end

  # GET /vocabularies/1
  # GET /vocabularies/1.json
  def show
    prefixes = {
      owl: RDF::OWL,
      rdfs: RDF::RDFS
    }
    respond_to do |format|
      format.html
      format.json { render plain: @vocabulary.graph.dump(:jsonld, prefixes: prefixes) }
      format.ttl { render plain: @vocabulary.graph.dump(:ttl, prefixes: prefixes) }
      format.nt { render plain: @vocabulary.graph.dump(:ntriples) }
    end
  end

  # GET /vocabularies/new
  def new
    @vocabulary = Vocabulary.new
  end

  # GET /vocabularies/1/edit
  def edit
  end

  # POST /vocabularies
  # POST /vocabularies.json
  def create # rubocop:disable Metrics/MethodLength
    @vocabulary = Vocabulary.new(vocabulary_params)

    respond_to do |format|
      if @vocabulary.save
        format.html do
          redirect_to @vocabulary, notice: "#{t('activerecord.models.vocabulary')} was successfully created."
        end
        format.json { render :show, status: :created, location: @vocabulary }
      else
        format.html { render :new }
        format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vocabularies/1
  # PATCH/PUT /vocabularies/1.json
  def update # rubocop:disable Metrics/MethodLength
    respond_to do |format|
      if @vocabulary.update(vocabulary_params)
        format.html do
          redirect_to @vocabulary, notice: "#{t('activerecord.models.vocabulary')} was successfully updated."
        end
        format.json { render :show, status: :ok, location: @vocabulary }
      else
        format.html { render :edit }
        format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vocabularies/1
  # DELETE /vocabularies/1.json
  def destroy
    @vocabulary.destroy
    respond_to do |format|
      format.html do
        redirect_to vocabularies_url, notice: "#{t('activerecord.models.vocabulary')} was successfully deleted."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_vocabulary
      @vocabulary = Vocabulary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vocabulary_params
      params.require(:vocabulary).permit(:identifier, :description)
    end
end
