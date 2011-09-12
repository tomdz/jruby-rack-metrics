require 'rubygems'
require 'java'

module JrubyRackMetrics
  class Monitor
    attr_writer :metrics_registry, :default_duration_unit, :default_rate_unit

    def initialize(app, name)
      @app = app
      @name = name
      @timing_unit = java.util.concurrent.TimeUnit::NANOSECONDS
    end

    def metrics_registry
      @metrics_registry ||= com.yammer.metrics.core.MetricsRegistry.new
    end

    def default_duration_unit
      @default_duration_unit ||= java.util.concurrent.TimeUnit::MILLISECONDS
    end

    def default_rate_unit
      @default_rate_unit ||= java.util.concurrent.TimeUnit::SECONDS
    end

    def call(env)
      start_time = java.lang.System.nanoTime()
      begin
        @app.call(env)
      ensure
        elapsed = java.lang.System.nanoTime() - start_time
        if env['REQUEST_URI'] == "/"
          type = "_root"
        else
          type = env['REQUEST_URI'].gsub(/[\/|\s|,|;|#|!]/, "_")
        end
        name = env['REQUEST_METHOD'].downcase
        metric_name = com.yammer.metrics.core.MetricName.new(@name, type, name)
        metrics_registry.newTimer(metric_name, default_duration_unit, default_rate_unit).update(elapsed, @timing_unit)
      end
    end
  end
end

