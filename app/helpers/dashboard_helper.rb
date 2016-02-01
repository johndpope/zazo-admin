module DashboardHelper
  def lazy_metric_chart(chart, metric, options = {})
    chartkick_chart chart.to_s.classify, data_metric_path(metric), options
  end
end
