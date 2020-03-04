# frozen_string_literal: true

class VocabulariesController < ApplicationController
  load_and_authorize_resource

  # GET /vocabularies
  # GET /vocabularies.json
  def index
    if params[:identifier].present?
      @vocabulary = Vocabulary.find_by! identifier: params[:identifier]
      render :show
    else
      @vocabularies = Vocabulary.all
    end
  end

  # GET /vocabularies/1
  # GET /vocabularies/1.json
  def show # rubocop:disable Metrics/AbcSize
    respond_to do |format|
      format.html
      format.json { render plain: @vocabulary.graph.dump(:jsonld, prefixes: Vocabulary::PREFIXES.dup) }
      format.ttl { render plain: @vocabulary.graph.dump(:ttl, prefixes: Vocabulary::PREFIXES.dup) }
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
  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @vocabulary = Vocabulary.new(vocabulary_params)

    respond_to do |format|
      if @vocabulary.save
        publish_rdf
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
    publish_rdf
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
    UnpublishVocabularyRdfJob.perform_later @vocabulary.identifier
    respond_to do |format|
      format.html do
        redirect_to vocabularies_url, notice: "#{t('activerecord.models.vocabulary')} was successfully deleted."
      end
      format.json { head :no_content }
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def vocabulary_params
      params.require(:vocabulary).permit(:identifier, :description)
    end

    def publish_rdf
      PublishVocabularyRdfJob.perform_later @vocabulary, 'jsonld', 'ttl', 'ntriples'
    end
end
