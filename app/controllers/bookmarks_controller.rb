# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks

  # Remove relevance sort
  # Note: The "score desc, display_title asc" key has to match
  # the add_sort_field configuration for relevance sort field
  # in CatalogController configuration
  blacklight_config.sort_fields.delete('score desc, display_title asc')

  # Hide Citation link in the Bookmarks view
  blacklight_config.show.document_actions[:citation].if = false

  add_show_tools_partial(:export, callback: :export)

  def export_selection(documents)
  end
end
