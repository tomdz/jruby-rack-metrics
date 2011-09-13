require 'rubygems'
require 'uri'
require 'java'
require 'rack'

module JrubyRackMetrics
  class Monitor
    attr_reader :options

    def initialize(app, opts = {})
      @app = app
      @options = default_options.merge(opts)
      @timing_unit = java.util.concurrent.TimeUnit::NANOSECONDS
      if @options[:jmx_enabled]
        com.yammer.metrics.reporting.JmxReporter.startDefault(metrics_registry)
      end
    end

    def default_options
      { :default_duration_unit => java.util.concurrent.TimeUnit::MILLISECONDS,
        :default_rate_unit => java.util.concurrent.TimeUnit::SECONDS,
        :jmx_enabled => false }
    end

    def metrics_registry
      @options[:metrics_registry] ||= com.yammer.metrics.Metrics.defaultRegistry
    end

    def call(env = nil)
      if env.nil?
        @app.call(env)
      else
        start_time = java.lang.System.nanoTime()
        begin
          status, headers, body = @app.call(env)
        ensure
          elapsed = java.lang.System.nanoTime() - start_time
          # some web servers give us the full url, some only the path part
          uri = URI.parse(env['REQUEST_URI'])
          if defined? uri.path && !uri.path.nil?
            if uri.path == "/"
              group = "_root"
            else
              group = uri.path.gsub(/[\/|\s|,|;|#|!|:]/, "_")
              group = group[1..-1] if group.start_with?("_")
            end
            type = env['REQUEST_METHOD'].downcase
            name = (status || 500).to_s
            metric_name = com.yammer.metrics.core.MetricName.new(group, type, name)
            metrics_registry.newTimer(metric_name,
                                      @options[:default_duration_unit],
                                      @options[:default_rate_unit]).update(elapsed, @timing_unit)
          end
        end
      end
    end
  end
end

