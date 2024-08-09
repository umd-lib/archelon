# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  # UMD Customization
  blacklight_config.add_show_tools_partial(:export, path: :new_export_job_url, modal: false)
  blacklight_config.add_show_tools_partial(:publish_job, path: :new_publish_job_url, modal: false, label: 'Publish')
  blacklight_config.add_show_tools_partial(:unpublish_job, path: :new_unpublish_job_url, modal: false, label: 'Unpublish')
  # End UMD Customization
end
