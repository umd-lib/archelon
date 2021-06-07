# frozen_string_literal: true

module UMDLibEnvironmentBannerHelper
  # True if the banner has been initialized, false otherwise
  @@banner_initialized = false
  # Holds the banner ibject
  @@banner = nil
  # Holds the HTML for the banner (if any)
  @@banner_html = nil

  # Initializes the banner
  def self.initialize
    # Uses @@banner_initialized to skip regenerating banner each time the
    # module is called.
    if !@@banner_initialized
      @@banner_initialized = true
      return if ENV['ENVIRONMENT_BANNER_ENABLED'] == 'false'

      # The EnvVarsEnvironmentBanner banner is used, if enabled, otherwise
      # defaults to the DevelopmentEnvironmentBanner implementation
      banner = EnvVarsEnvironmentBanner.new
      if !banner.enabled?
        banner = DevelopmentEnvironmentBanner.new
      end

      @@banner = banner

      if @@banner.enabled?
        # Configure banner HTML
        css_options = @@banner.css_options
        # Sort to get consistent ordering of keys
        css_string = css_options.sort.to_h.map { |key,value| "#{key}='#{value}'" }.join(" ")
        banner_text = @@banner.text
        @@banner_html = "<div #{css_string}>#{banner_text}</div>".html_safe
        return @@banner_html
      else
        @@banner_html = nil
      end
    end

    @@banner
  end

  # Resets the banner -- intended be used only for testing
  def self.reset
    @@banner_initialized = false
    @@banner = nil
    @@banner_html = nil
  end

  # https://confluence.umd.edu/display/LIB/Create+Environment+Banners
  #
  def umd_lib_environment_banner
    UMDLibEnvironmentBannerHelper.initialize if !@@banner_initialized
    @@banner_html
  end

  # Banner implementation classes -- these are not intended to be called
  # directly

    # Returns an environment banner based on ENV config properties
    class EnvVarsEnvironmentBanner
      attr_accessor :text
      attr_accessor :css_options

      def initialize
        @text = banner_text
        @css_options = banner_css_options
        @enabled = banner_enabled(@text)
      end

      # Returns the text to display in the environment banner.
      #
      # Implementation: Returns the value of the ENVIRONMENT_BANNER property, if
      # non-empty.
      #
      # This method may return nil, if there is no ENVIRONMENT_BANNER
      def banner_text
        banner_text = ENV.has_key?('ENVIRONMENT_BANNER') ? ENV['ENVIRONMENT_BANNER'] : ''
        if !banner_text.empty?
           ENV['ENVIRONMENT_BANNER'].freeze
        end
      end

      # Returns the CSS options to use with the environment banner.
      #
      # Implementation: Uses the ENVIRONMENT_BANNER_BACKGROUND and
      # ENVIRONMENT_BANNER_FOREGROUND properties, if provided.
      def banner_css_options
        css_options = {}
        css_style = ''

        background_color = ENV.has_key?('ENVIRONMENT_BANNER_BACKGROUND') ? ENV['ENVIRONMENT_BANNER_BACKGROUND'] : ''
        foreground_color = ENV.has_key?('ENVIRONMENT_BANNER_FOREGROUND') ? ENV['ENVIRONMENT_BANNER_FOREGROUND'] : ''

        if !background_color.empty?
          css_style = "background-color: #{background_color};"
        end

        if !foreground_color.empty?
          css_style += " color: #{foreground_color};"
          css_style.strip!
        end

        if !css_style.empty?
          css_options[:style] = css_style
        end

        css_options[:class] = 'environment-banner'
        css_options
      end

      # Returns true if the banner should be displayed, false otherwise.
      #
      # text - the text (if any) being displayed in the banner
      def banner_enabled(text)
        env_var_enabled = ENV['ENVIRONMENT_BANNER_ENABLED']
        env_var_enabled = ENV.has_key?('ENVIRONMENT_BANNER_ENABLED') ? ENV['ENVIRONMENT_BANNER_ENABLED'] : ''

        # Don't display the banner if there is no text
        has_display_text = !text.nil? && !text.empty?
        return false unless has_display_text

        # Display if ENVIRONMENT_BANNER_ENABLED is not provided or empty
        return true if env_var_enabled.nil? || env_var_enabled.empty?

        # Any value other than "true" is false
        env_var_enabled.strip.downcase == 'true'
      end

      def enabled?
        @enabled
      end
    end

  # Returns a default environment banner for Rails development environment
  class DevelopmentEnvironmentBanner
    attr_accessor :text
    attr_accessor :css_options

    def initialize
      environment_name = environment_name()
      if environment_name.nil?
        @enabled = false
        return
      end
      @text = "#{environment_name} Environment"
      @css_options = {}
      @css_options[:id] = "environment-#{environment_name.downcase}"
      @css_options[:class] = "environment-banner"
      @enabled = !environment_name.empty?
    end

    def enabled?
      @enabled
    end

    private

      def environment_name
        ( Rails.env.development? || Rails.env.vagrant? ) ? "Local" : nil
      end
  end
end

# here we reopen the ApplicationController (after Rails has started)
# and stick in our helper module.
Rails.application.config.after_initialize do
    ApplicationController.class_eval do
      include UMDLibEnvironmentBannerHelper
      helper_method :umd_lib_environment_banner
    end
end