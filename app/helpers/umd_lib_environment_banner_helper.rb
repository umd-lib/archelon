module UMDLibEnvironmentBannerHelper
  # https://confluence.umd.edu/display/LIB/Create+Environment+Banners
  def umd_lib_environment_banner
    if Rails.env.development?
      environment = 'Local'
    else
      hostname = `hostname -s`
      if hostname =~ /dev$/
        environment = 'Development'
      elsif hostname =~ /stage$/
        environment = 'Staging'
      end
    end
    if environment
      content_tag :div, "#{environment} Environment",
        class: 'environment-banner',
        id: "environment-#{environment.downcase}"
    end
  end
end
