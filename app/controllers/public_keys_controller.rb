# frozen_string_literal: true

# Public keys controller
class PublicKeysController < ApplicationController
  skip_before_action :authenticate

  def index

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

end
