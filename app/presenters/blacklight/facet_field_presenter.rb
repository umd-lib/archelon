# frozen_string_literal: true

module Blacklight
  # Customized two methods from Blacklight::FacetFieldPresenter for dealing with
  # facet limits when in a modal vs on the main page on the sidebar.
  # Can't monkeypatch in sadly, tried to used include to get the original
  # But it doesn't work
  class FacetFieldPresenter
    attr_reader :facet_field, :display_facet, :view_context, :search_state

    delegate :key, to: :facet_field
    delegate :field_name, to: :display_facet

    def initialize(facet_field, display_facet, view_context, search_state = view_context.search_state)
      @facet_field = facet_field
      @display_facet = display_facet
      @view_context = view_context
      @search_state = search_state
    end

    def collapsed?
      !active? && facet_field.collapse
    end

    def active?
      search_state.filter(facet_field).any?
    end

    def in_modal?
      search_state.params[:action] == 'facet'
    end

    def modal_path
      return unless paginator

      view_context.search_facet_path(id: key) unless paginator&.last_page?
    end

    def label
      view_context.facet_field_label(key)
    end

    def values
      search_state&.filter(facet_field)&.values || []
    end

    # Appease rubocop rules by implementing #each_value
    def each_value(&block)
      values.each(&block)
    end

    def paginator
      return unless display_facet

      @paginator ||= blacklight_config.facet_paginator_class.new(
        display_facet.items,
        sort: display_facet.sort,
        offset: display_facet.offset,
        prefix: display_facet.prefix,
        # UMD Customization
        # When in the modal, use the default_more_limit from the blacklight configuration,
        # otherwise grab what's set in the config, which can be set or unset
        # Unset means unlimited
        limit: in_modal? ? blacklight_config.default_more_limit : facet_limit
      )
    end

    # UMD Customization: Updated for Rubocop Metrics/AbcSize
    def facet_limit
      return unless facet_field.limit

      @display_facet ? display_facet_limit : default_facet_limit
    end

    private

      def display_facet_limit
        limit = @display_facet.limit
        return inferred_limit if limit.nil?
        return nil if limit == -1

        limit.to_i - 1
      end

      def inferred_limit
        facet_field.limit unless facet_field.limit == true
      end

      def default_facet_limit
        facet_field.limit == true ? blacklight_config.default_more_limit : facet.limit
      end
      # End UMD Customization

      delegate :blacklight_config, to: :search_state
  end
end
