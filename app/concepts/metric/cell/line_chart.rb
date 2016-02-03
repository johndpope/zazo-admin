class Metric::Cell::LineChart < Metric::Cell
  def self.view
    :chart
  end

  def chart
    line_chart data, height: '350px', id: chart_id
  end
end
