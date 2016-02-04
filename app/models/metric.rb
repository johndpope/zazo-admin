require 'metric/data'

class Metric
  METRICS_PARAMS = [
    { name: :users_device_platform, type: :pie_chart },
    { name: :users_status, type: :pie_chart },
    { name: :active_users, type: :aggregated_by_timeframe },
    { name: :messages_sent, type: :aggregated_by_timeframe },
    { name: :usage_by_active_users, type: :aggregated_by_timeframe },
    { name: :upload_duplications_data },
    { name: :onboarding_info },
    { name: :invitation_funnel },
    { name: :non_marketing_invitations_sent },
    { name: :non_marketing_registered_by_weeks, type: :line_chart },
    { name: :invitation_conversion },
    { name: :messages_failures },
    { name: :messages_failures_autonotification, type: :messages_failures },
    { name: :messages_statuses_between_users }
  ]

  METRICS_TO_RENDER = [
    :active_users,
    :messages_sent,
    :usage_by_active_users,
    :onboarding_info,
    :non_marketing_registered_by_weeks,
    :invitation_funnel,
    :non_marketing_invitations_sent,
    :invitation_conversion,
    :messages_failures,
    :messages_failures_autonotification,
    :upload_duplications_data
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

    def find_by_name(name)
      find_by :name, name
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
