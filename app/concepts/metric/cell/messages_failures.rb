class Metric::Cell::MessagesFailures < Metric::Cell
  def total_attribute
    model.data[:meta][:total]
  end
end
