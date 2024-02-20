class PublishJobController < BookmarksController
  FIELD_LISTS = [
    'title',
    'component',
    'rdf_type',
    'collection_title_facet',
    'citation',
    'handle',
    'is_published',
    'is_hidden',
    'is_discoverable'
  ]

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

  def view
    @id = params[:id]
    job = PublishJob.find(@id)
    @publish = job.publish
    @result_documents = job.solr_ids.map { |solr_id| fetch(solr_id)[1] }
    @name = job.cas_user.cas_directory_id
    @status = job.status

    @hidden = @result_documents.sum { |doc| (doc._source.include? "is_hidden" && doc._source["is_hidden"] == "true") ? 1 : 0 }
    @published = @result_documents.sum { |doc| (doc._source.include? "is_published" && doc._source["is_published"] == "true") ? 1 : 0 }
    @unpublished = @result_documents.length - @published
  end

  def new_publish_job
    solr_ids = current_user.bookmarks.map(&:document).map { |doc| doc.id }
    create_job(solr_ids, true, "Submission pending")
    redirect_to "/publish_job"
  end

  def new_unpublish_job
    solr_ids = current_user.bookmarks.map(&:document).map { |doc| doc.id }
    create_job(solr_ids, false, "Submission pending")
    redirect_to "/publish_job"
  end

  def destroy
    PublishJob.destroy(params[:id])
    redirect_to "/publish_job"
  end

  def submit
    PublishJob.find(params[:id]).update(:status => "Job in progress")
    redirect_to "/publish_job"
  end

  private
    def create_job(ids, publish, status)
      PublishJob.create(:solr_ids => ids,
                        :publish => publish,
                        :cas_user => current_cas_user,
                        :status => status)
    end
end
