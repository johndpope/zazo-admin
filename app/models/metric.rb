require 'metric/data'

class Metric
  METRICS_PARAMS = [
    { name: :onboarding_info },
    { name: :messages_failures },
    { name: :messages_failures_autonotification, type: :messages_failures }
  ]

  METRICS_TO_RENDER = [
    :onboarding_info,
    :messages_failures,
    :messages_failures_autonotification
  ]

  class << self
    def all
      build_from_params METRICS_PARAMS
    end

    def to_render
      METRICS_TO_RENDER.map do |name|
        find_by :name, name
      end.compact
    end

    def find_by(attribute, value)
      metric_params = METRICS_PARAMS.find { |params| params[attribute] == value.to_sym }
      build_from_params(metric_params).first if metric_params
    end

    private

    def build_from_params(metrics_params)
      Array.wrap(metrics_params).map { |params| new params }
    end
  end

  attr_reader :name, :type, :data, :options

  def initialize(name:, type: nil)
    @name = name
    @type = type || name
    @options = {}
  end

  def data(options = {})
    @options = options
    @data ||= Metric::Data.get_data name, options
  end
end
