class Metric::Cell::OnboardingInfo < Metric::Cell
  def self.view
    :chart
  end

  def chart
    new_data = data.keys.map { |key| { name: key, data: data[key] } }
    line_chart new_data, height: '800px', min: -5, max: 100, id: chart_id
  end
end
