module MetricsHelper
  def link_to_metric(metric)
    link_to "#{metric.name.to_s.titleize}", metric_path(metric.name)
  end
end
