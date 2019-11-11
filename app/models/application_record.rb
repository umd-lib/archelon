# frozen_string_literal: true

# Abstract base class for model classes.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
