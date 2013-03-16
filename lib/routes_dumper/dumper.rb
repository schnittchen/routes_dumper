# encoding: utf-8

module RoutesDumper
  module Dumper
    ControllerRoute = Struct.new(:name, :verb, :path, :controller, :action) do
      def group_key
        [path, controller]
      end

      def formatted_group_head
        "#{(controller + ' ').ljust(50, '·')} ✈ #{path}"
      end

      def individual_line
        " ‣ #{verb.ljust(8)} ##{stripped_action.ljust(30)} #{name}"
      end

      def stripped_action
        if me = %r( {).match(action)
          me.pre_match
        else
          action
        end
      end
    end

    RackAppRoute = Struct.new(:name, :verb, :path, :reqs) do
      def group_key
        reqs
      end

      def formatted_group_head
        "Rack application: #{reqs}"
      end

      def individual_line
        " ‣ #{verb.ljust(8)} #{" "* 31} #{name}"
      end
    end

    class Formatter
      def initialize(routes_hashes)
        @routes_hashes = routes_hashes
        @result = ''
      end

      def result
        pre_processed_routes.group_by(&:group_key).values.each do |routes|
          @result << routes.first.formatted_group_head << "\n"

          routes.each do |route|
            @result << "#{route.individual_line}\n"
          end
        end
        @result
      end

      def pre_processed_routes
        @pre_processed_routes ||= @routes_hashes.map do |routes_hash|
          nameverbpath = routes_hash.values_at(:name, :verb, :path)
          if reqs = routes_hash[:reqs] and reqs.include?('#')
            ControllerRoute.new(*nameverbpath, *reqs.split('#'))
          else
            RackAppRoute.new(*nameverbpath, reqs)
          end
        end
      end
    end

    class << self
      def format
        all_routes = Rails.application.routes.routes

        require 'rails/application/route_inspector'
        inspector = Rails::Application::RouteInspector.new

        routes_hashes = inspector.collect_routes(all_routes)

        formatter = Formatter.new(routes_hashes)
        formatter.result
      end

      def hijack_reloader
        require 'rails/application/routes_reloader'

        target = Rails::Application::RoutesReloader
        target.send :alias_method, :original_reload!, :reload!
        target.send :define_method, :reload! do
          original_reload!
          RoutesDumper::Dumper.dump_to_file
        end
      end

      def dump_to_file
        File.open(Rails.application.root.join('routes.txt'), 'w') do |f|
          f << format
        end
      end
    end
  end
end
