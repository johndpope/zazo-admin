class Metric::Cell::AggregatedByTimeframe < Metric::Cell
  def chart_by(period)
    area_chart data_metric_path(group_by: period), id: chart_id
  end
end
