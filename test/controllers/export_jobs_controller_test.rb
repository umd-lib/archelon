# frozen_string_literal: true

require 'test_helper'
require_relative './mock_stomp_client'

STOMP_CLIENT = MockStompClient.instance
class ExportJobsControllerTest < ActionController::TestCase
  setup do
    @cas_user = cas_users(:test_admin)
    mock_cas_login(@cas_user.cas_directory_id)

    Rails.application.configure do
      config.queues = {
        export_jobs: '/queue/exportjobs',
        export_jobs_completed: '/queue/exportjobs.completed'
      }
    end
  end

  test 'create new export job' do
    assert_difference('ExportJob.count') do
      uris = 'http://example.com/1\nhttp://example.com/2'
      params = {}
      params[:uris] = uris
      params[:export_job] = { name: 'test1', format: 'CSV' }

      post :create, params: params
    end
  end
end
