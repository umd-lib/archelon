# frozen_string_literal: true

module UMDLibEnvironmentBannerHelper
  # https://confluence.umd.edu/display/LIB/Create+Environment+Banners
  def umd_lib_environment_banner
    current_env = environment_name
    return unless current_env

    text = "#{current_env} Environment"
    id = "environment-#{current_env.downcase}"
    content_tag :div, text, class: 'environment-banner', id: id
  end

  def environment_name
    return 'Local' if Rails.env.development? || Rails.env.vagrant?
    hostname = `hostname -s`
    return 'Development' if hostname =~ /dev$/
    return 'Staging' if hostname =~ /stage$/
  end
end
