class MetricsController < AdminController
  before_action :validate_group_by, only: [:show]

  def index
    metrics_list = events_api.metric_list
    @metrics = metrics_list.is_a?(Array) && Settings.allowed_metrics.each_with_object([]) do |name, memo|
      metric = metrics_list.find { |m| m['name'] == name }
      memo << Metric.new(metric) if metric
    end
  end

  def view
    @metric = Metric.new metric_params
  end

  def show
    events_metric params[:id]
  end

  def options
    session[Metric::Options::SESSION_KEY] = Metric::Options.new(params[:id]).get_by_params(params)
    redirect_to request.referer
  end

  private

  def events_metric(metric)
    render json: events_api.metric_data(metric, group_by: @group_by)
  end

  def validate_group_by
    @group_by = params[:group_by].try(:to_sym) || :day
    @group_by.in?(Groupdate::FIELDS) || render_error("invalid group_by value: #{@group_by.inspect}, valid fields are #{Groupdate::FIELDS}")
  end

  def settings_params
    @params ||= {
      invitation_funnel: %w(start_date end_date)
    }.stringify_keys
  end

  def metric_params
    [:name, :type].each_with_object(params) { |key, obj| obj.require key }.except(:action, :controller)
  end
end
