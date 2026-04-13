# frozen_string_literal: true

# Mixin for adding resource_service capabilities to a controller
module ResourceServiceConcern
  extend ActiveSupport::Concern

  included do
    def resource_service
      @resource_service ||= ResourceService.new(
        endpoint: FCREPO_ENDPOINT,
        origin: FCREPO_ORIGIN,
        auth_token: FCREPO_AUTH_TOKEN
      )
    end
  end
end
