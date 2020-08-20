# frozen_string_literal: true

# Public keys controller
class PublicKeysController < ApplicationController
  skip_before_action :authenticate

  def index
    # only allow this to be viewed from localhost
    forbidden && return unless requested_from_localhost?

    keys = []

    # include the Plastron public key from the environment, if set
    keys << PLASTRON_PUBLIC_KEY if PLASTRON_PUBLIC_KEY.present?

    CasUser.all.each do |user|
      user.public_keys.find_each do |public_key|
        keys << public_key.key
      end
    end
    render plain: keys.join("\n")
  end

  private

    def requested_from_localhost?
      request.remote_ip =~ /^127\./ || request.remote_ip == '::1'
    end
end
