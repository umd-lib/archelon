class PublishJob < ApplicationRecord
  serialize :solr_ids, Array
end
