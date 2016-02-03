class Metric::Cell::RateLineChart < Metric::Cell
  def self.view
    :chart
  end

  def chart
    line_chart [{ name: 'rate', data: data }], height: '500px', id: chart_id
  end
end
