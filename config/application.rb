require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RssPack
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.test_framework :rspec,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       request_specs: false
    end

    config.i18n.default_locale = :ja

    routes.default_url_options[:host] = ENV["RSSPACK_HOSTNAME"]
    routes.default_url_options[:port] = ENV["RSSPACK_PORT"]
    routes.default_url_options[:protocol] = "https" if Rails.env.production?

    # Enable rack-dev-mark
    config.rack_dev_mark.enable = !Rails.env.production?
    #
    # Customize the env string (default Rails.env)
    # config.rack_dev_mark.env = 'foo'
    #
    # Customize themes if you want to do so
    # config.rack_dev_mark.theme = [:title, :github_fork_ribbon]
    #
    # Customize inserted place of the middleware if necessary.
    # You can use either `insert_before` or `insert_after`
    # config.rack_dev_mark.insert_before SomeOtherMiddleware
    # config.rack_dev_mark.insert_after SomeOtherMiddleware
  end
end
