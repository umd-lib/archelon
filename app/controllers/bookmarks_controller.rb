# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  # UMD Customization
  blacklight_config.add_show_tools_partial(:export, path: :new_export_job_url, modal: false)
  # End UMD Customization
end
