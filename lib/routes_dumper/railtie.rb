require 'routes_dumper/dumper'

module RoutesDumper
  class Railtie < Rails::Railtie
    initializer "routes_dumper.hijack_reloader" do
      RoutesDumper::Dumper.hijack_reloader if Rails.env.development?
    end
  end
end
