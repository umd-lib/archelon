# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  # UMD Blacklight 8 Fix
  # It is not currently clear if any of these methods are needed
  # If none of these methods are uncommented, this file can be deleted.

  # application_name is set in config/locales/blacklight.en.yml
  # def application_name
  #   'Archelon'
  # end

  # ##
  # # Get the document's "title" to display in the <title> element.
  # # (by default, use the #document_heading)
  # #
  # # @see #document_heading
  # # @param [SolrDocument] document
  # # @return [String]
  # def document_show_html_title(document = nil)
  #   display_title = fedora_resource_title
  #   return display_title if display_title

  #   super(document)
  # end

  # ##
  # # Render the document "heading" (title) in a content tag
  # # @overload render_document_heading(document, options)
  # #   @param [SolrDocument] document
  # #   @param [Hash] options
  # #   @option options [Symbol] :tag
  # # @overload render_document_heading(options)
  # #   @param [Hash] options
  # #   @option options [Symbol] :tag
  # #
  # # Overridden to return the Fedora resource title, if available
  # def render_document_heading(*args)
  #   display_title = fedora_resource_title
  #   if display_title
  #     options = args.extract_options!
  #     tag = options.fetch(:tag, :h4)
  #     content_tag(tag, display_title, itemprop: 'name')
  #   else
  #     super(*args)
  #   end
  # end

  # # Retrieves the display title using Fedora resource data, or nil
  # def fedora_resource_title
  #   return unless @resource && @id

  #   ResourceService.display_title(@resource, @id)
  # end

  # End UMD Blacklight 8 Fix
end
