require 'test_helper'

class UMDLibEnvironmentBannerHelperTest < ActiveSupport::TestCase
  def setup
    @banner = Object.new
    @banner.extend(UMDLibEnvironmentBannerHelper)
  end

  test 'Development environment returns local banner by default' do
    Rails.env = 'development'
    assert_equal("<div class='environment-banner' id='environment-local'>Local Environment</div>",
                 @banner.umd_lib_environment_banner)
  end

  test 'Vagrant environment returns local banner by default' do
    Rails.env = 'vagrant'
    assert_equal("<div class='environment-banner' id='environment-local'>Local Environment</div>",
                 @banner.umd_lib_environment_banner)
  end

  test 'Banner text can be controlled by ENVIRONMENT_BANNER' do
    ENV['ENVIRONMENT_BANNER'] = 'Testing123'
    assert_equal("<div class='environment-banner'>Testing123</div>",
                 @banner.umd_lib_environment_banner)
  end

  test 'Banner foreground color can be controlled by ENVIRONMENT_BANNER_FOREGROUND' do
    ENV['ENVIRONMENT_BANNER'] = 'TestingForeground'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    assert_equal("<div class='environment-banner' style='color: #ff0000;'>TestingForeground</div>",
                 @banner.umd_lib_environment_banner)
  end

  test 'Banner background color can be controlled by ENVIRONMENT_BANNER_BACKGROUND' do
    ENV['ENVIRONMENT_BANNER'] = 'TestingBackground'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#ff00ff'
    assert_equal("<div class='environment-banner' style='background-color: #ff00ff;'>TestingBackground</div>",
                 @banner.umd_lib_environment_banner)
  end

  test 'Banner foreground and background color can be controlled by environment variables' do
    ENV['ENVIRONMENT_BANNER'] = 'TestingForeBack'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#777777'
    assert_equal(
      "<div class='environment-banner' style='background-color: #777777; color: #ff0000;'>TestingForeBack</div>",
      @banner.umd_lib_environment_banner)
  end

  test 'A ENVIRONMENT_BANNER_ENABLED of "true" enables banner display' do
    ENV['ENVIRONMENT_BANNER'] = 'BannerEnabledTrue'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#777777'
    ENV['ENVIRONMENT_BANNER_ENABLED'] = 'true'
    assert_equal(
      "<div class='environment-banner' style='background-color: #777777; color: #ff0000;'>BannerEnabledTrue</div>",
      @banner.umd_lib_environment_banner)
  end

  test 'A blank ENVIRONMENT_BANNER_ENABLED enables banner display' do
    ENV['ENVIRONMENT_BANNER'] = 'BannerEnabledBlank'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#777777'
    ENV['ENVIRONMENT_BANNER_ENABLED'] = ''
    assert_equal(
      "<div class='environment-banner' style='background-color: #777777; color: #ff0000;'>BannerEnabledBlank</div>",
      @banner.umd_lib_environment_banner)
  end

  test 'ENVIRONMENT_BANNER_ENABLED of "false" prevents banner display' do
    ENV['ENVIRONMENT_BANNER'] = 'BannerEnabledFalse'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#777777'
    ENV['ENVIRONMENT_BANNER_ENABLED'] = 'false'
    assert_nil(@banner.umd_lib_environment_banner)
  end

  test 'Non-blank ENVIRONMENT_BANNER_ENABLED other than "true" prevents banner display' do
    ENV['ENVIRONMENT_BANNER'] = 'BannerEnabledFoobar'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#777777'
    ENV['ENVIRONMENT_BANNER_ENABLED'] = 'foobar'
    assert_nil(@banner.umd_lib_environment_banner)
  end

  test 'Banner is not displayed by default in production' do
    Rails.env = 'production'
    assert_nil(@banner.umd_lib_environment_banner)
  end

  test 'Banner can be displayed in production using environment variables' do
    Rails.env = 'production'

    ENV['ENVIRONMENT_BANNER'] = 'TestingProdWithEnv'
    ENV['ENVIRONMENT_BANNER_FOREGROUND'] = '#ff0000'
    ENV['ENVIRONMENT_BANNER_BACKGROUND'] = '#777777'
    assert_equal(
      "<div class='environment-banner' style='background-color: #777777; color: #ff0000;'>TestingProdWithEnv</div>",
      @banner.umd_lib_environment_banner)
  end

  def teardown
    # Unset environment variables
    Rails.env = 'test'
    ENV.clear

    # Reset the module
    UMDLibEnvironmentBannerHelper.reset
  end
end
