# frozen_string_literal: true

# A publish job from Fedora
class PublishJob < ApplicationRecord
  belongs_to :cas_user
  serialize :solr_ids, Array
end
