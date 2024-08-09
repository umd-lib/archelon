# frozen_string_literal: true

# Controller for displaying interactive React components on a form.
class ReactComponentsController < ApplicationController
  # POST
  def react_components_submit
    @params = params
  end
end
