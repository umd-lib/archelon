# frozen_string_literal: true

# Public keys controller
class PublicKeysController < ApplicationController
  skip_before_action :authenticate

  def index
    # only allow this to be viewed from localhost
    forbidden && return unless requested_from_localhost?

    keys = ''
    CasUser.all.each do |user|
      user.public_keys.find_each do |public_key|
        keys += public_key.key + "\n"
      end
    end
    render plain: keys
  end

  private

    def requested_from_localhost?
      request.remote_ip =~ /^127\./ || request.remote_ip == '::1'
    end
end
