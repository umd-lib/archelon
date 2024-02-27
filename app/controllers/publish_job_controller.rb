# frozen_string_literal: true

class PublishJobController < BookmarksController
  before_action :set_publish_job, only: %i[update show edit start_publish status_update]

  FIELD_LISTS = %w[
    title
    component
    rdf_type
    collection_title_facet
    citation
    handle
    is_published
    is_hidden
    is_discoverable
  ].freeze

  configure_blacklight do |config|
    config.add_facet_fields_to_solr_request = false
    config.fetch_many_document_params = {
      qt: 'document',
      fl: FIELD_LISTS.join(','),
      facet: false
    }
  end

  add_show_tools_partial(:export, path: :new_export_job_url, modal: false)

  def index
    @jobs =
      if current_cas_user.admin?
        PublishJob.all.order('updated_at DESC')
      else
        PublishJob.where(cas_user: current_cas_user).order('updated_at DESC')
      end
  end

  def view # rubocop:disable Metrics/AbcSize
    id = params[:id]
    @job = PublishJob.find(id)
    @result_documents = @job.solr_ids.map { |solr_id| fetch(solr_id)[1] }

    @hidden = @result_documents.sum do |doc|
      doc._source.include?('is_hidden') && doc._source['is_hidden'] == true ? 1 : 0
    end

    @published = @result_documents.sum do |doc|
      doc._source.include?('is_published') && doc._source['is_published'] == true ? 1 : 0
    end

    @unpublished = @result_documents.length - @published
  end

  def new_publish_job
    solr_ids = current_user.bookmarks.map(&:document).map(&:id)
    create_job(solr_ids, true, 1)
    redirect_to '/publish_job'
  end

  def new_unpublish_job
    solr_ids = current_user.bookmarks.map(&:document).map(&:id)
    create_job(solr_ids, false, 1)
    redirect_to '/publish_job'
  end

  def destroy
    PublishJob.destroy(params[:id])
    redirect_to '/publish_job'
  end

  def submit
    PublishJob.find(params[:id]).update(state: 2)
    start_publish
    redirect_to '/publish_job'
  end

  # Generates status text display for the GUI
  def status_text(publish_job)
    return '' if publish_job.state.blank?

    return I18n.t("activerecord.attributes.publish_job.status.#{publish_job.state}") unless publish_job.publish_in_progress?

    I18n.t('activerecord.attributes.publish_job.status.publish_in_progress') + publish_job.progress_text
  end

   # POST /publish_job/1/status_update
   def status_update
    # Triggers import job notification to channel;
    # it is important to use perform_now so that
    # ActionCable receives timely updates
    PublishJobStatusUpdatedJob.perform_now(@publish_job)
    render plain: '', status: :no_content
  end

  private

    def set_publish_job
      @publish_job = PublishJob.find(params[:id])
    end

    def create_job(ids, publish, state)
      PublishJob.create(solr_ids: ids,
                        publish: publish,
                        cas_user: current_cas_user,
                        state: state)
    end

    def job_request(job, validate_only: false, resume: false)
      PublishJobRequest.create(
        publish_job: job,
        job_id: publish_job_url(job),
        resume: resume
      )
    end

    def start_publish
      SendStompMessageJob.perform_later jobs_destination, job_request(@publish_job)
      @publish_job.publish_pending!
    end

    def resume_publish
      SendStompMessageJob.perform_later jobs_destination, job_request(@publish_job, resume: true)
      @publish_job.publish_pending!
    end
end
