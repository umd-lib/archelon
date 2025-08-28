# frozen_string_literal: true

# Component for displaying an Archelon-based "backlink" to the parent/container
# of a Solr document, i.e., a link back to the container in which the current
# item is contained.
#
# Given a Solr document, extracts the specified field from the document (the
# value is assumed to an fcrepo URL), then queries Solr, retrieving the
# Solr document to backlink to.
#
# The component then does the following:
#
#   1) The fcrepo URL is converted into a Archelon-based URL for the same item.
#
#   2) Using the the provided "backlink_text_field" or
#      "backlink_text_accessor" field (see below), generates human-readable
#      text to display with the link.
#
# This component adds the following fields to the field configuration:
#
# * backlink_text_field - the field in the retrieved Solr document to use
#   as the human-readable text for the link.
#
# * backlink_text_accessor - the SolrDocument method to call on the retrieved
#   Solr document to generate the human-readable text for the link.
#
# Typically, only one of these fields is provided. If both are provided, the
# "backlink_text_accessor" field will take precedence.
#
# If neither field is provided, the link will be returned AS-IS, with the
# human-readable text being the value of the Solr field.
#
# Note: This component makes a Solr query for each instance where it is used
# on a page.
class ArchelonBacklinkComponent < Blacklight::MetadataFieldComponent
  def before_render
    backlink_document_id = @field.field_config.key
    backlink_document = controller.search_service.fetch(@field.document[backlink_document_id])

    @backlink_text, @backlink_url = generate_backlink(@field, backlink_document)
  end

  # Generates an Archelon-based backlink based on the given field configuration
  # and Solr document
  #
  # Returns a two-part array [<backlink title>, <backlink URL>], representing
  # the human-readable link text, and URL.
  def generate_backlink(field, backlink_document)
    if field.field_config.key?(:backlink_text_accessor)
      backlink_from_accessor(field, backlink_document)
    elsif @field.field_config.key?(:backlink_text_field)
      backlink_from_field(field, backlink_document)
    else
      default_backlink(field)
    end
  end

  private

    # Create backlink from "backlink_text_accessor" field configuration
    #
    # Returns a two-part array [<backlink title>, <backlink URL>], representing
    # the human-readable link text, and URL.
    def backlink_from_accessor(field, backlink_document)
      backlink_text_accessor = field.field_config[:backlink_text_accessor]
      backlink_text = backlink_document.send(backlink_text_accessor)
      backlink_url = solr_document_url(field.render)

      [backlink_text, backlink_url]
    end

    # Create backlink from "backlink_text_accessor" field configuration
    #
    # Returns a two-part array [<backlink title>, <backlink URL>], representing
    # the human-readable link text, and URL.
    def backlink_from_field(field, backlink_document)
      backlink_text_field = field.field_config[:backlink_text_field]
      backlink_text = backlink_document[backlink_text_field]
      backlink_url = solr_document_url(field.render)

      [backlink_text, backlink_url]
    end

    # Default - convert link to Archelon-based link with link as text
    # Note: This is "fallback" behavior and likely not ideal. Consider
    # specifying a "backlink_text_field" or "backlink_text_accessor"
    # to get more human-friendly link text.
    #
    # Returns a two-part array [<backlink title>, <backlink URL>], representing
    # the human-readable link text, and URL.
    def default_backlink(field)
      backlink_text = solr_document_url(field.render)
      backlink_url = solr_document_url(field.render)

      [backlink_text, backlink_url]
    end
end
