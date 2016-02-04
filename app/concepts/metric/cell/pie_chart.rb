class Metric::Cell::PieChart < Metric::Cell
  def self.view
    :chart
  end

  def chart
    pie_chart data_metric_path(name), id: chart_id
  end
end
