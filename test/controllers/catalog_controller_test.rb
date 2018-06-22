require 'test_helper'

class CatalogControllerTest < ActionController::TestCase
  test 'should give warning and redirect if solr is down' do
    raise_e = -> { raise Blacklight::Exceptions::ECONNREFUSED }
    @controller.stub(:index, raise_e) do
      get :index
      assert_redirected_to(about_url)
      refute flash.empty?
      assert_equal flash[:error], I18n.t(:solr_is_down)
    end
  end
end
