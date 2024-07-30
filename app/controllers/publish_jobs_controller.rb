# frozen_string_literal: true

class PublishJobsController < BookmarksController # rubocop:disable  Metrics/ClassLength
  before_action :set_publish_job, only: %i[submit start_publish status_update]

  helper_method :status_text
  skip_before_action :authenticate, only: %i[status_update]
  skip_before_action :verify_authenticity_token, only: :status_update
  skip_before_action :verify_user, only: :status_update

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

  # UMD Blacklight 8 Fix
  blacklight_config.add_show_tools_partial(:export, path: :new_export_job_url, modal: false)
  # End UMD Blacklight 8 Fix

  def index
    @jobs =
      if current_cas_user.admin?
        PublishJob.all.order('updated_at DESC')
      else
        PublishJob.where(cas_user: current_cas_user).order('updated_at DESC')
      end
  end

  def show # rubocop:disable Metrics/AbcSize
    id = params[:id]
    @job = PublishJob.find(id)
    # UMD Blacklight 8 Fix
    @result_documents = @job.solr_ids.map { |solr_id| search_service.fetch(solr_id) }

    @hidden = @result_documents.sum do |doc|
      doc._source.include?('is_hidden') && doc._source['is_hidden'] == true ? 1 : 0
    end

    @published = @result_documents.sum do |doc|
      doc._source.include?('is_published') && doc._source['is_published'] == true ? 1 : 0
    end
    # End UMD Blacklight 8 Fix

    @unpublished = @result_documents.length - @published
  end

  def new_publish_job
    solr_ids = current_user.bookmarks.map(&:document).map(&:id)
    job = create_job(solr_ids, true, 1, false)
    redirect_to publish_job_url(job)
  end

  def new_unpublish_job
    solr_ids = current_user.bookmarks.map(&:document).map(&:id)
    job = create_job(solr_ids, false, 1, false)
    redirect_to publish_job_url(job)
  end

  def destroy
    PublishJob.destroy(params[:id])
    redirect_to publish_jobs_url, status: :see_other
  end

  def submit # rubocop:disable Metrics/AbcSize
    job = PublishJob.find(params[:id])
    force_hidden = !params[:publish_job].nil? ? params[:publish_job][:force_hidden] == '1' : job.force_hidden

    job.update!(state: 2, force_hidden: force_hidden)
    start_publish
    redirect_to publish_jobs_url, status: :see_other
  end

  # Generates status text display for the GUI
  def status_text(publish_job)
    return '' if publish_job.state.blank?

    return I18n.t("activerecord.attributes.publish_job.status.#{publish_job.state}") unless publish_job.publish_in_progress? # rubocop:disable Metrics/LineLength

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

  # Blacklight 8 Fix
  # Making this method public, because otherwise Rails 7.1 displays and
  # "Unknown action" error when using the controller.
  def start_publish
    SendStompMessageJob.perform_later jobs_destination, job_request(@publish_job)
    @publish_job.publish_pending!
  end
  # End Blacklight 8 Fix

  private

    def set_publish_job
      @publish_job = PublishJob.find(params[:id])
    end

    def create_job(ids, publish, state, force_hidden)
      PublishJob.create(solr_ids: ids,
                        publish: publish,
                        cas_user: current_cas_user,
                        state: state,
                        force_hidden: force_hidden,
                        name: "#{current_cas_user.cas_directory_id}-#{Time.now.iso8601}")
    end

    def job_request(job, resume: false)
      PublishJobRequest.create(
        publish_job: job,
        job_id: publish_job_url(job),
        resume: resume
      )
    end

    def jobs_destination
      STOMP_CONFIG['destinations'][:jobs]
    end

    def resume_publish
      SendStompMessageJob.perform_later jobs_destination, job_request(@publish_job, resume: true)
      @publish_job.publish_pending!
    end
end
