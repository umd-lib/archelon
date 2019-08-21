# frozen_string_literal: true

# Bookmarks / Selected-Items Model
class Bookmark < ApplicationRecord
  belongs_to :cas_user, polymorphic: true
  belongs_to :document, polymorphic: true

  validates :user_id, presence: true

  attr_accessible :id, :document_id, :document_type, :title if Blacklight::Utils.needs_attr_accessible?

  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    value = super if defined?(super)
    value &&= value.constantize
    value || default_document_type
  end

  def default_document_type
    SolrDocument
  end
end
