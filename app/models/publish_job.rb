class PublishJob < ApplicationRecord
  belongs_to :cas_user
  serialize :solr_ids, Array
end
